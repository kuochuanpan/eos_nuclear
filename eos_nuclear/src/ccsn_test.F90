program ccsn_test

  use eosmodule
  implicit none


  real*8 xrho,xye,xtemp,xtemp2
  real*8 xenr,xprs,xent,xcs2,xdedt,xmunu
  real*8 xdpderho,xdpdrhoe
  integer keytemp,keyerr

  ! for full eos call:
  real*8 xabar,xzbar,xmu_e,xmu_n,xmu_p,xmuhat
  real*8 xxa,xxh,xxn,xxp
  

  ! for ccsn test
  real*8  :: tmp
  integer, parameter :: npoints  = 600
  integer :: i
  real*8, dimension(npoints) :: radius, mass, dens, yele , velr, temp
  real*8, dimension(npoints) :: pres, entr, ynu1, ynu2, znu1, znu2

  ! vary dens, ye, and temp(pres)
  integer :: j,k,l
  real*8, parameter  :: fract1= 10.0    ! for dens, temp, pres
  real*8, parameter  :: fract2= 1.1    ! for ye

  real*8 :: temp1, temp2, dens1, dens2
  integer :: total, tot_failed
  real*8 :: err, max_err, ave_err

  open(100,file="data_s20GREP_LS220_nonupres_15ms.data",status='OLD')
  read(100, *) 
  do i = 1, npoints
    read(100,*) radius(i), mass(i), dens(i), yele(i), velr(i),&
                temp(i), pres(i), entr(i), ynu1(i), ynu2(i), znu1(i), znu2(i)
  enddo
  close(100)
  print *, "KC: model readed. npoints = ", npoints


  keytemp = 1
  keyerr  = 0

  xrho = 10.0d0**1.474994d1
  xtemp = 63.0d0
  xye = 0.2660725d0

  call readtable("LS220.h5")

  total      = 0
  tot_failed = 0
  max_err    = 0.0
  ave_err    = 0.0

  do i = 1, npoints

      print *, "n=", i
      !do j = -1, 1
      !  do k = -1, 1
      !    do l = -1, 1

            total = total + 1

            !keytemp = 1 ! temperature mode
            keyerr  = 0

            xrho  = dens(i) * 3.0 !* (fract1**j) ! trial density

            xtemp = temp(i)/temp_mev_to_kelvin  !max(temp(i)/temp_mev_to_kelvin * (fract1**k),eos_tempmin)
            xye   = yele(i) !* (fract2**l)
            xprs  = pres(i)

            !temp1 = xtemp
            dens1 = dens(i) ! true density
            !xtemp = min(max(eos_tempmin, xtemp),eos_tempmax)
            !print *, "temp",xtemp
            keytemp = 3    ! pressure mode

            call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
                xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)

            print *, "d,ye,t,s,u", xrho,xye,xtemp,xent,xenr


            !call nuc_eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
            !    xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p,&
            !    xmuhat,keytemp,keyerr,precision)

            !keytemp = 3    ! pressure mode

            !xrho  = xrho !* 1.5 ! guess density

            !call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
            !    xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)

            !call nuc_eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
            !    xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p,&
            !    xmuhat,keytemp,keyerr,precision)

            !temp2 = xtemp
            dens2 = xrho  ! solved density

            !print *, "rel error =", abs(temp2-temp1)/(temp1)
            err = abs(dens2-dens1)/(dens1)
            print *, "rel error =", err
            max_err = max(err, max_err)
            ave_err = ave_err + err
            if (err  .ge. 1.e-3) then
               tot_failed = tot_failed + 1
               print *, xrho,xtemp,xye, xprs
            endif

       ! enddo
      !enddo
    !enddo
  enddo

  print *, "KC: pressure mode OK!"
  print *, "KC: failed /total", tot_failed, total
  print *, "KC: max error:", max_err
  print *, "KC: ave error:", ave_err/float(total)

  stop

  keytemp = 3

  do i = 1, npoints
      do j = -1, 1
        do k = -1, 1
          do l = -1, 1

            xrho  = dens(i) !*1.2 !* (fract1**j)
            xtemp = temp(i)/temp_mev_to_kelvin * (3.**j)
            xprs  = pres(i) * (3.**k)
            xye   = yele(i) * (1.05**l)

            !xtemp = min(max(eos_tempmin, xtemp),eos_tempmax)
            !print *, "temp",xtemp

            call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
                xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)

            call nuc_eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
                xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p,&
                xmuhat,keytemp,keyerr,precision)

        enddo
      enddo
    enddo
  enddo

  stop

! keyerr --> error output; should be 0
! rfeps --> root finding relative accuracy, set around 1.0d-10
! keytemp: 0 -> coming in with eps
!          1 -> coming in with temperature
!          2 -> coming in with entropy
!          3 -> coming in with pressure

  ! short eos call
  call nuc_eos_short(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
       xdpderho,xdpdrhoe,xmunu,keytemp,keyerr,precision)

  write(6,*) "######################################"
  write(6,"(1P10E15.6)") xrho,xtemp,xye
  write(6,"(1P10E15.6)") xenr,xprs,xent,sqrt(xcs2)
  write(6,"(1P10E15.6)") xdedt,xdpdrhoe,xdpderho
  write(6,*) "######################################"

  ! full eos call
  call nuc_eos_full(xrho,xtemp,xye,xenr,xprs,xent,xcs2,xdedt,&
       xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p,&
       xmuhat,keytemp,keyerr,precision)

  write(6,*) "Full EOS: ############################"
  write(6,"(1P10E15.6)") xrho,xtemp,xye
  write(6,"(1P10E15.6)") xenr,xprs,xent,sqrt(xcs2)
  write(6,"(1P10E15.6)") xdedt,xdpdrhoe,xdpderho
  write(6,"(1P10E15.6)") xabar,xzbar
  write(6,"(1P10E15.6)") xxa,xxh,xxn,xxp
  write(6,"(1P10E15.6)") xmu_e,xmu_p,xmu_n,xmuhat
  write(6,*) "######################################"

  
  xtemp2 = 2.0d0*xtemp
  keytemp = 0

  call nuc_eos_full(xrho,xtemp2,xye,xenr,xprs,xent,xcs2,xdedt,&
       xdpderho,xdpdrhoe,xxa,xxh,xxn,xxp,xabar,xzbar,xmu_e,xmu_n,xmu_p,&
       xmuhat,keytemp,keyerr,precision)

  write(6,*) "Full EOS: ############################"
  write(6,"(1P10E15.6)") xrho,xtemp2,xtemp,xye
  write(6,"(1P10E15.6)") xenr,xprs,xent,sqrt(xcs2)
  write(6,"(1P10E15.6)") xdedt,xdpdrhoe,xdpderho
  write(6,"(1P10E15.6)") xabar,xzbar
  write(6,"(1P10E15.6)") xxa,xxh,xxn,xxp
  write(6,"(1P10E15.6)") xmu_e,xmu_p,xmu_n,xmuhat
  write(6,*) "######################################"



end program ccsn_test
