!-----------------------------------------------------------------------------
! A f2py interface to use the EosDriver from stellarcollaspe.org
!
! The original EosDriver is written by C. D. Ott and E. O'Connor, July 2009
!
! the python wrapper and the f2py interface is written by Kuo-Chuan Pan, March 2016
!
!-----------------------------------------------------------------------------


!---------------------------------------------------------------------------
! inital and read the eos table

subroutine init_table(tablename)
    implicit none
    character (len=120) :: tablename
    call readtable(tablename)
end subroutine init_table

subroutine del_table()
    use eosmodule, only : alltables, logrho,logtemp,ye
    implicit none
    deallocate(alltables)
    deallocate(logrho)
    deallocate(logtemp)
    deallocate(ye)
end subroutine del_table

!---------------------------------------------------------------------------

subroutine eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
        xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p, &
        xmuhat,keytemp,keyerr)

    use eosmodule, only : precision
    implicit none
    real*8, intent(in)    :: xye
    real*8, intent(inout) :: xrho,xtemp,xenr,xent,xprs
    real*8, intent(out)   :: xcs2,xdedt
    real*8, intent(out)   :: xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp
    real*8, intent(out)   :: xabar,xzbar,xmu_e,xmu_n,xmu_p,xmuhat
    integer, intent(in)   :: keytemp
    integer, intent(out)  :: keyerr

!f2py intent(out) xrho,xtemp,xenr,xent
!f2py intent(out) xprs,xcs2,xdedt,xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp
!f2py intent(out) xabar,xzbar,xmu_e,xmu_n,xmu_p,xmuhat,keyerr

    call nuc_eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
        xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p, &
        xmuhat,keytemp,keyerr,precision)

end subroutine eos_full

!---------------------------------------------------------------------------
subroutine eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xzdedt,&
        xdpderho,xdpdrhoe,xmunu,keytemp,keyerr)

    use eosmodule, only : precision
    implicit none
    real*8, intent(in)    :: xye
    real*8, intent(inout) :: xrho,xtemp,xenr,xent,xprs
    real*8, intent(out)   :: xmunu,xcs2,xzdedt
    real*8, intent(out)   :: xdpderho,xdpdrhoe
    integer, intent(in)   :: keytemp
    integer, intent(out)  :: keyerr

!f2py intent(out) xrho,xtemp,xenr,xent
!f2py intent(out) xprs,xmunu,xcs2,xzdedt,xdpderho,xdpdrhoe,keyerr

    call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xzdedt,&
        xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)

end subroutine eos_short

!---------------------------------------------------------------------------
! Get the energy shift from the EOS table
!
subroutine get_energy_shift(ezero)
    use eosmodule, only : energy_shift
    implicit none
    real*8 ezero
!f2py intent(out) ezero    
    ezero = energy_shift
end subroutine get_energy_shift


!---------------------------------------------------------------------------
! Get the internal energy (with energy shift) from Rho, Ye, and Temperature
!

subroutine get_eint(xrho,xye,xtemp,xenr)
    use eosmodule, only : energy_shift, precision
    implicit none
    real*8 xrho,xtemp,xye,xenr,xprs,xent,xcs2,xzdedt,xdpderho,xdpdrhoe, xmunu
    integer keytemp, keyerr
!f2py intent(out) xenr
    keytemp = 1
    call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xzdedt,&
                       xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)
    xenr = xenr + energy_shift
end subroutine get_eint

!---------------------------------------------------------------------------
! Batch version of eos_short: process N points in one call
! OpenMP parallelized for performance
!
subroutine eos_short_batch(n,xrho,xtemp,xye,xenr,xprs,xent,xcs2,xzdedt,&
        xdpderho,xdpdrhoe,xmunu,keytemp,keyerr)

    use eosmodule, only : precision
    implicit none
    integer, intent(in) :: n
    real*8, dimension(n), intent(in)    :: xye
    real*8, dimension(n), intent(inout) :: xrho,xtemp,xenr,xent,xprs
    real*8, dimension(n), intent(out)   :: xmunu,xcs2,xzdedt
    real*8, dimension(n), intent(out)   :: xdpderho,xdpdrhoe
    integer, intent(in)   :: keytemp
    integer, dimension(n), intent(out)  :: keyerr

!f2py intent(in) n, keytemp
!f2py intent(in) xye
!f2py intent(in,out) xrho, xtemp, xenr, xent, xprs
!f2py intent(out) xcs2, xzdedt, xdpderho, xdpdrhoe, xmunu, keyerr
!f2py depend(n) xrho, xtemp, xye, xenr, xprs, xent
!f2py depend(n) xcs2, xzdedt, xdpderho, xdpdrhoe, xmunu, keyerr

    integer :: i

    !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(i) SCHEDULE(dynamic, 64)
    do i = 1, n
        call nuc_eos_short(xrho(i),xtemp(i),xye(i),xenr(i),xprs(i),&
             xent(i),xcs2(i),xzdedt(i),xdpderho(i),xdpdrhoe(i),&
             xmunu(i),keytemp,keyerr(i),precision)
    end do
    !$OMP END PARALLEL DO

end subroutine eos_short_batch

!---------------------------------------------------------------------------
! Batch version of eos_full: process N points in one call
! OpenMP parallelized for performance
!
subroutine eos_full_batch(n,xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
        xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p, &
        xmuhat,keytemp,keyerr)

    use eosmodule, only : precision
    implicit none
    integer, intent(in) :: n
    real*8, dimension(n), intent(in)    :: xye
    real*8, dimension(n), intent(inout) :: xrho,xtemp,xenr,xent,xprs
    real*8, dimension(n), intent(out)   :: xcs2,xdedt
    real*8, dimension(n), intent(out)   :: xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp
    real*8, dimension(n), intent(out)   :: xabar,xzbar,xmu_e,xmu_n,xmu_p,xmuhat
    integer, intent(in)   :: keytemp
    integer, dimension(n), intent(out)  :: keyerr

!f2py intent(in) n, keytemp
!f2py intent(in) xye
!f2py intent(in,out) xrho, xtemp, xenr, xent, xprs
!f2py intent(out) xcs2, xdedt, xdpderho, xdpdrhoe
!f2py intent(out) xxa, xxh, xxn, xxp, xabar, xzbar
!f2py intent(out) xmu_e, xmu_n, xmu_p, xmuhat, keyerr
!f2py depend(n) xrho, xtemp, xye, xenr, xprs, xent
!f2py depend(n) xcs2, xdedt, xdpderho, xdpdrhoe
!f2py depend(n) xxa, xxh, xxn, xxp, xabar, xzbar
!f2py depend(n) xmu_e, xmu_n, xmu_p, xmuhat, keyerr

    integer :: i

    !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(i) SCHEDULE(dynamic, 64)
    do i = 1, n
        call nuc_eos_full(xrho(i),xtemp(i),xye(i),xenr(i),xprs(i),&
             xent(i),xcs2(i),xdedt(i),xdpderho(i),xdpdrhoe(i),&
             xxa(i),xxh(i),xxn(i),xxp(i),xabar(i),xzbar(i),&
             xmu_e(i),xmu_n(i),xmu_p(i),xmuhat(i),&
             keytemp,keyerr(i),precision)
    end do
    !$OMP END PARALLEL DO

end subroutine eos_full_batch


!---------------------------------------------------------------------------

subroutine get_boundaries(dmin,dmax,tmin,tmax,ymin,ymax)
    use eosmodule
    implicit none
    real*8 dmin, dmax
    real*8 tmin, tmax
    real*8 ymin, ymax
!f2py intent(out) dmin,dmax,tmin,tmax,ymin,ymax
    dmin = eos_rhomin
    dmax = eos_rhomax
    ymin = eos_yemin
    ymax = eos_yemax
    tmin = eos_tempmin
    tmax = eos_tempmax
end subroutine get_boundaries



