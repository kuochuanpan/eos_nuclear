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



