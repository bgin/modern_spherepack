!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                      SPHEREPACK version 3.2                   *
!     *                                                               *
!     *       A Package of Fortran Subroutines and Programs           *
!     *                                                               *
!     *              for Modeling Geophysical Processes               *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *                  John Adams and Paul Swarztrauber             *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
! ... file tvshifte.f is a test program illustrating the
!     use of subroutine vshifte (see documentation for vshifte)
!
! ... required spherepack files
!
!     type_HFFTpack.f, vshifte.f
!
!     Let the analytic vector field (u,v) in geophysical coordinates be
!     given by
!
!          u  = -exp(x)*sin(p) + exp(-z)*cos(p) + exp(y)*sin(t)*sin(p)
!
!          v  = exp(y)*cos(p) + exp(z)*cos(t) - exp(x)*sin(t)*cos(p)
!
!     where t is the latitude coordinate, p is the longitude coordinate,
!     and x=cos(t)*cos(p),y=cos(t)*sin(p),z=sin(t) are the cartesian coordinates
!     restricted to the sphere.

!     The "offset" vector field (uoff,voff) is set equal to (u,v).
!     This is transferred to the "regular" grid in (ureg,vreg).  (ureg,vreg)
!     is then compared with (u,v) on the regular grid.  Finally (ureg,vreg)
!     is transferred back to (uoff,voff) which is again compared with (u,v).
!     The least squares error after each transformation with vshifte
!     is computed and printed.  Results from running the program on
!     a 2.5 degree equally spaced regular and offset grid is given.
!     Output from runs on separate platforms with 32 bit and 64 bit
!     floating point arithmetic is listed.
!
! *********************************************
!     OUTPUT
! *********************************************
!
!       vshifte arguments
!       ioff =  0 nlon = 144 nlat =  72
!       lsave =   608 lwork = 21024
!       ier =  0
!       least squares error
! ***   32 BIT ARITHMETIC
!       err2u =  0.377E-06 err2v =  0.328E-06
! ***   64 BIT ARITHMETIC
!       err2u =  0.777E-13 err2v =  0.659E-13

!       vshifte arguments
!       ioff =  1 nlon = 144 nlat =  72
!       lsave =   608 lwork = 21024
!       ier =  0
!       least squares error
! ***   32 BIT ARITHMETIC
!       err2u =  0.557E-06 err2v =  0.434E-06
! ***   64 BIT AIRTHMETIC
!       err2u =  0.148E-12 err2v =  0.118E-12
!
! *********************************************
!     END OF OUTPUT (CODE FOLLOWS)
! *********************************************
!
program testvshifte

    use, intrinsic :: ISO_Fortran_env, only: &
        stdout => OUTPUT_UNIT

    use spherepack_library, only: &
        wp, & ! working precision
        TWO_PI, pi, vshifti, vshifte

    ! Explicit typing only
    implicit none

    integer nnlon,nnlat,nnlatp1,nnlat2,llsave,llwork
    !
    !     set equally spaced grid sizes in nnlat,nnlon
    !
    parameter(nnlon=144,nnlat=72)
    !
    !     set parameters which depend on nnlat,nnlon
    !
    parameter(nnlatp1=nnlat+1,nnlat2=2*nnlat)
    !     save work space
    parameter (llsave=2*(2*nnlat+nnlon)+32)
    !     unsaved work space for nnlon even
    parameter (llwork = 2*nnlon*(nnlat+1))
    !     unsaved work space for nnlon odd
    !     parameter (llwork = nnlon*(5*nnlat+1))
    integer ioff,nlon,nlat,nlat2,j,i,lsave,lwork,ierror
    real dlat,dlon,dlat2,dlon2,lat,long,x,y,z,ex,ey,ez,emz
    real err2u,err2v,ue,ve,sint,sinp,cost,cosp
    real uoff(nnlon,nnlat),voff(nnlon,nnlat)
    real ureg(nnlon,nnlatp1),vreg(nnlon,nnlatp1)
    real wsave(llsave),work(llwork)

    write( *, '(/a/)') '     testvshifte *** TEST RUN *** '

    !
    !     set resolution, work space lengths, and grid increments
    !
    nlat = nnlat
    nlon = nnlon
    lsave = llsave
    nlat2 = nnlat2
    lwork = llwork
    dlat = pi/nlat
    dlon = TWO_PI/nlon
    dlat2 = 0.5*dlat
    dlon2 = 0.5*dlon
    !
    !     set (uoff,voff) = (u,v) on offset grid
    !
    do j=1,nlon
        long = dlon2+(j-1)*dlon
        sinp = sin(long)
        cosp = cos(long)
        do i=1,nlat
            lat = -0.5*pi+dlat2+(i-1)*dlat
            sint = sin(lat)
            cost = cos(lat)
            x = cost*cosp
            y = cost*sinp
            z = sint
            ex = exp(x)
            ey = exp(y)
            ez = exp(z)
            emz = exp(-z)
            uoff(j,i) =-ex*sinp+emz*cost+ey*sint*sinp
            voff(j,i) = ey*cosp+ez*cost-ex*sint*cosp
        end do
    end do
    !
    !    initialize wsav for offset to regular shift
    !
    ioff = 0
    call vshifti(ioff,nlon,nlat,lsave,wsave,ierror)
    !
    !     write input arguments to vshifte
    !
    write( stdout, 100) ioff,nlon,nlat,lsave,lwork
100 format(' vshifte arguments', &
        /' ioff = ',i2, ' nlon = ',i3,' nlat = ',i3, &
        /' lsave = ',i5, ' lwork = ',i5)
    !
    !     shift offset to regular grid
    !
    call vshifte(ioff,nlon,nlat,uoff,voff,ureg,vreg, &
        wsave,lsave,work,lwork,ierror)
    write( stdout, 200) ierror
200 format(' ierror = ',i2)
    if (ierror==0) then
        !
        !     compute error in ureg,vreg
        !
        err2u = 0.0_wp
        err2v = 0.0_wp
        do j=1,nlon
            long = real(j-1, kind=wp)*dlon
            sinp = sin(long)
            cosp = cos(long)
            do i=1,nlat+1
                lat = -0.5_wp * pi+real(i-1, kind=wp)*dlat
                sint = sin(lat)
                cost = cos(lat)
                x = cost*cosp
                y = cost*sinp
                z = sint
                ex = exp(x)
                ey = exp(y)
                ez = exp(z)
                emz = exp(-z)
                ue = -ex*sinp+emz*cost+ey*sint*sinp
                ve = ey*cosp+ez*cost-ex*sint*cosp
                err2u = err2u + (ureg(j,i)-ue)**2
                err2v = err2v + (vreg(j,i)-ve)**2
            end do
        end do
        err2u = sqrt(err2u/(nlon*(nlat+1)))
        err2v = sqrt(err2v/(nlon*(nlat+1)))
        write( stdout, 300) err2u,err2v
300     format(' least squares error ', &
            /' err2u = ',e10.3, ' err2v = ',e10.3)
    end if
    !
    !    initialize wsav for regular to offset shift
    !
    ioff = 1
    call vshifti(ioff,nlon,nlat,lsave,wsave,ierror)
    !
    !     transfer regular grid values in (ureg,vreg) to offset grid in (uoff,voff)
    !
    do j=1,nlon
        do i=1,nlat
            uoff(j,i) = 0.0_wp
            voff(j,i) = 0.0_wp
        end do
    end do
    write( stdout, 100) ioff,nlon,nlat,lsave,lwork
    call vshifte(ioff,nlon,nlat,uoff,voff,ureg,vreg, &
        wsave,lsave,work,lwork,ierror)
    if (ierror == 0) then
        !
        !     compute error in uoff,voff
        !
        err2u = 0.0_wp
        err2v = 0.0_wp
        do j=1,nlon
            long = dlon2+(j-1)*dlon
            sinp = sin(long)
            cosp = cos(long)
            do i=1,nlat
                lat = -0.5_wp*pi+dlat2+(i-1)*dlat
                sint = sin(lat)
                cost = cos(lat)
                x = cost*cosp
                y = cost*sinp
                z = sint
                ex = exp(x)
                ey = exp(y)
                ez = exp(z)
                emz = exp(-z)
                ue = -ex*sinp+emz*cost+ey*sint*sinp
                ve = ey*cosp+ez*cost-ex*sint*cosp
                err2u = err2u + (uoff(j,i)-ue)**2
                err2v = err2v + (voff(j,i)-ve)**2
            end do
        end do
        err2u = sqrt(err2u/(nlon*(nlat+1)))
        err2v = sqrt(err2v/(nlon*(nlat+1)))
        write( stdout, 300) err2u,err2v
    end if

end program testvshifte
