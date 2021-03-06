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
!
! ... file vtses.f
!
!     this file includes documentation and code for
!     subroutines vtses and vtsesi
!
! ... files which must be loaded with vtses.f
!
!     type_SpherepackAux.f, type_HFFTpack.f, vhaes.f, vhses.f
!   
!   
!     subroutine vtses(nlat, nlon, ityp, nt, vt, wt, idvw, jdvw, br, bi, cr, ci, 
!    +                 mdab, ndab, wvts, lwvts, work, lwork, ierror)
!
!     given the vector harmonic analysis br, bi, cr, and ci (computed
!     by subroutine vhaes) of some vector function (v, w), this 
!     subroutine computes the vector function (vt, wt) which is
!     the derivative of (v, w) with respect to colatitude theta. vtses
!     is similar to vhses except the vector harmonics are replaced by 
!     their derivative with respect to colatitude with the result that
!     (vt, wt) is computed instead of (v, w). vt(i, j) is the derivative
!     of the colatitudinal component v(i, j) at the point theta(i) =
!     (i-1)*pi/(nlat-1) and longitude phi(j) = (j-1)*2*pi/nlon. the
!     spectral representation of (vt, wt) is given below at output
!     parameters vt, wt.
!
!     input parameters
!
!     nlat   the number of colatitudes on the full sphere including the
!            poles. for example, nlat = 37 for a five degree grid.
!            nlat determines the grid increment in colatitude as
!            pi/(nlat-1).  if nlat is odd the equator is located at
!            grid point i=(nlat+1)/2. if nlat is even the equator is
!            located half way between points i=nlat/2 and i=nlat/2+1.
!            nlat must be at least 3. note: on the half sphere, the
!            number of grid points in the colatitudinal direction is
!            nlat/2 if nlat is even or(nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     ityp   = 0  no symmetries exist about the equator. the synthesis
!                 is performed on the entire sphere. i.e. the arrays
!                 vt(i, j), wt(i, j) are computed for i=1, ..., nlat and
!                 j=1, ..., nlon.   
!
!            = 1  no symmetries exist about the equator however the
!                 the coefficients cr and ci are zero. the synthesis
!                 is performed on the entire sphere.  i.e. the arrays
!                 vt(i, j), wt(i, j) are computed for i=1, ..., nlat and
!                 j=1, ..., nlon.
!
!            = 2  no symmetries exist about the equator however the
!                 the coefficients br and bi are zero. the synthesis
!                 is performed on the entire sphere.  i.e. the arrays
!                 vt(i, j), wt(i, j) are computed for i=1, ..., nlat and 
!                 j=1, ..., nlon.
!
!            = 3  vt is odd and wt is even about the equator. the 
!                 synthesis is performed on the northern hemisphere
!                 only.  i.e., if nlat is odd the arrays vt(i, j), wt(i, j)
!                 are computed for i=1, ...,(nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even the arrays vt(i, j), wt(i, j) are computed 
!                 for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 4  vt is odd and wt is even about the equator and the 
!                 coefficients cr and ci are zero. the synthesis is
!                 performed on the northern hemisphere only. i.e. if
!                 nlat is odd the arrays vt(i, j), wt(i, j) are computed
!                 for i=1, ...,(nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the arrays vt(i, j), wt(i, j) are computed for 
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 5  vt is odd and wt is even about the equator and the 
!                 coefficients br and bi are zero. the synthesis is
!                 performed on the northern hemisphere only. i.e. if
!                 nlat is odd the arrays vt(i, j), wt(i, j) are computed
!                 for i=1, ...,(nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the arrays vt(i, j), wt(i, j) are computed for 
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 6  vt is even and wt is odd about the equator. the 
!                 synthesis is performed on the northern hemisphere
!                 only.  i.e., if nlat is odd the arrays vt(i, j), wt(i, j)
!                 are computed for i=1, ...,(nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even the arrays vt(i, j), wt(i, j) are computed 
!                 for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 7  vt is even and wt is odd about the equator and the 
!                 coefficients cr and ci are zero. the synthesis is
!                 performed on the northern hemisphere only. i.e. if
!                 nlat is odd the arrays vt(i, j), wt(i, j) are computed
!                 for i=1, ...,(nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the arrays vt(i, j), wt(i, j) are computed for 
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 8  vt is even and wt is odd about the equator and the 
!                 coefficients br and bi are zero. the synthesis is
!                 performed on the northern hemisphere only. i.e. if
!                 nlat is odd the arrays vt(i, j), wt(i, j) are computed
!                 for i=1, ...,(nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the arrays vt(i, j), wt(i, j) are computed for 
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!     nt     the number of syntheses.  in the program that calls vtses, 
!            the arrays vt, wt, br, bi, cr, and ci can be three dimensional
!            in which case multiple syntheses will be performed.
!            the third index is the synthesis index which assumes the 
!            values k=1, ..., nt.  for a single synthesis set nt=1. the
!            discription of the remaining parameters is simplified
!            by assuming that nt=1 or that all the arrays are two
!            dimensional.
!
!     idvw   the first dimension of the arrays vt, wt as it appears in
!            the program that calls vtses. if ityp .le. 2 then idvw
!            must be at least nlat.  if ityp .gt. 2 and nlat is
!            even then idvw must be at least nlat/2. if ityp .gt. 2
!            and nlat is odd then idvw must be at least(nlat+1)/2.
!
!     jdvw   the second dimension of the arrays vt, wt as it appears in
!            the program that calls vtses. jdvw must be at least nlon.
!
!     br, bi  two or three dimensional arrays (see input parameter nt)
!     cr, ci  that contain the vector spherical harmonic coefficients
!            of (v, w) as computed by subroutine vhaes.
!            
!     mdab   the first dimension of the arrays br, bi, cr, and ci as it
!            appears in the program that calls vtses. mdab must be at
!            least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!     ndab   the second dimension of the arrays br, bi, cr, and ci as it
!            appears in the program that calls vtses. ndab must be at
!            least nlat.
!
!     wvts   an array which must be initialized by subroutine vtsesi.
!            once initialized, wvts can be used repeatedly by vtses
!            as long as nlon and nlat remain unchanged.  wvts must
!            not be altered between calls of vtses.
!
!     lwvts  the dimension of the array wvts as it appears in the
!            program that calls vtses. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 =(nlat+1)/2    if nlat is odd
!
!            then lwvts must be at least
!
!                 l1*l2*(nlat+nlat-l1+1)+nlon+15
!
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls vtses. define
!
!               l2 = nlat/2        if nlat is even or
!               l2 =(nlat+1)/2    if nlat is odd
!
!            if ityp .le. 2 then lwork must be at least
!
!                       (2*nt+1)*nlat*nlon
!
!            if ityp .gt. 2 then lwork must be at least
!
!                        (2*nt+1)*l2*nlon 
!
!     **************************************************************
!
!     output parameters
!
!     vt, wt  two or three dimensional arrays (see input parameter nt)
!            in which the derivative of (v, w) with respect to 
!            colatitude theta is stored. vt(i, j), wt(i, j) contain the
!            derivatives at colatitude theta(i) = (i-1)*pi/(nlat-1)
!            and longitude phi(j) = (j-1)*2*pi/nlon. the index ranges
!            are defined above at the input parameter ityp. vt and wt
!            are computed from the formulas for v and w given in 
!            subroutine vhses but with vbar and wbar replaced with
!            their derivatives with respect to colatitude. these
!            derivatives are denoted by vtbar and wtbar. 
!
!
!   *************************************************************
!
!   in terms of real variables this expansion takes the form
!
!             for i=1, ..., nlat and  j=1, ..., nlon
!
!     vt(i, j) = the sum from n=1 to n=nlat-1 of
!
!               .5*br(1, n+1)*vtbar(0, n, theta(i))
!
!     plus the sum from m=1 to m=mmax-1 of the sum from n=m to 
!     n=nlat-1 of the real part of
!
!       (br(m+1, n+1)*vtbar(m, n, theta(i))
!                   -ci(m+1, n+1)*wtbar(m, n, theta(i)))*cos(m*phi(j))
!      -(bi(m+1, n+1)*vtbar(m, n, theta(i))
!                   +cr(m+1, n+1)*wtbar(m, n, theta(i)))*sin(m*phi(j))
!
!    and for i=1, ..., nlat and  j=1, ..., nlon
!
!     wt(i, j) = the sum from n=1 to n=nlat-1 of
!
!              -.5*cr(1, n+1)*vtbar(0, n, theta(i))
!
!     plus the sum from m=1 to m=mmax-1 of the sum from n=m to
!     n=nlat-1 of the real part of
!
!      -(cr(m+1, n+1)*vtbar(m, n, theta(i))
!                   +bi(m+1, n+1)*wtbar(m, n, theta(i)))*cos(m*phi(j))
!      +(ci(m+1, n+1)*vtbar(m, n, theta(i))
!                   -br(m+1, n+1)*wtbar(m, n, theta(i)))*sin(m*phi(j))
!
!
!      br(m+1, nlat), bi(m+1, nlat), cr(m+1, nlat), and ci(m+1, nlat) are
!      assumed zero for m even.
!
!
!     ierror = 0  no errors
!            = 1  error in the specification of nlat
!            = 2  error in the specification of nlon
!            = 3  error in the specification of ityp
!            = 4  error in the specification of nt
!            = 5  error in the specification of idvw
!            = 6  error in the specification of jdvw
!            = 7  error in the specification of mdab
!            = 8  error in the specification of ndab
!            = 9  error in the specification of lwvts
!            = 10 error in the specification of lwork
!
!
! *******************************************************************
!
!     subroutine vtsesi(nlat, nlon, wvts, lwvts, work, lwork, dwork, ldwork, 
!    +                  ierror)
!
!     subroutine vtsesi initializes the array wvts which can then be
!     used repeatedly by subroutine vtses until nlat or nlon is changed.
!
!     input parameters
!
!     nlat   the number of colatitudes on the full sphere including the
!            poles. for example, nlat = 37 for a five degree grid.
!            nlat determines the grid increment in colatitude as
!            pi/(nlat-1).  if nlat is odd the equator is located at
!            grid point i=(nlat+1)/2. if nlat is even the equator is
!            located half way between points i=nlat/2 and i=nlat/2+1.
!            nlat must be at least 3. note: on the half sphere, the
!            number of grid points in the colatitudinal direction is
!            nlat/2 if nlat is even or(nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     lwvts  the dimension of the array wvts as it appears in the
!            program that calls vtses. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 =(nlat+1)/2    if nlat is odd
!
!            then lwvts must be at least
!
!                  l1*l2*(nlat+nlat-l1+1)+nlon+15
!
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls vtses. lwork must be at least
!
!              3*(max(l1-2, 0)*(nlat+nlat-l1-1))/2+5*l2*nlat
!
!     dwork  a real work array that does have to be saved.
!
!     ldwork the length of dwork.  ldwork must be at least 2*(nlat+1)
!
!     **************************************************************
!
!     output parameters
!
!     wvts   an array which is initialized for use by subroutine vtses.
!            once initialized, wvts can be used repeatedly by vtses
!            as long as nlat or nlon remain unchanged.  wvts must not
!            be altered between calls of vtses.
!
!
!     ierror = 0  no errors
!            = 1  error in the specification of nlat
!            = 2  error in the specification of nlon
!            = 3  error in the specification of lwvts
!            = 4  error in the specification of lwork
!            = 5  error in the specification of ldwork
!
!
module module_vtses

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use type_HFFTpack, only: &
        HFFTpack

    use type_SpherepackAux, only: &
        SpherepackAux

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    public :: vtses
    public :: vtsesi

contains

    subroutine vtses(nlat, nlon, ityp, nt, vt, wt, idvw, jdvw, br, bi, cr, ci, &
        mdab, ndab, wvts, lwvts, work, lwork, ierror)

        real(wp) :: bi
        real(wp) :: br
        real(wp) :: ci
        real(wp) :: cr
        integer(ip) :: idv
        integer(ip) :: idvw
        integer(ip) :: idz
        integer(ip) :: ierror
        integer(ip) :: imid
        integer(ip) :: ist
        integer(ip) :: ityp
        integer(ip) :: iw1
        integer(ip) :: iw2
        integer(ip) :: iw3
        integer(ip) :: iw4
        integer(ip) :: jdvw
        integer(ip) :: jw1
        integer(ip) :: jw2
        integer(ip) :: lnl
        integer(ip) :: lwork
        integer(ip) :: lwvts
        integer(ip) :: lzimn
        integer(ip) :: mdab
        integer(ip) :: mmax
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: vt
        real(wp) :: work
        real(wp) :: wt
        real(wp) :: wvts
        !
        dimension vt(idvw, jdvw, *), wt(idvw, jdvw, *), br(mdab, ndab, *), &
            bi(mdab, ndab, *), cr(mdab, ndab, *), ci(mdab, ndab, *), &
            work(*), wvts(*)


        ierror = 1
        if(nlat < 3) return
        ierror = 2
        if (nlon < 1) return
        ierror = 3
        if (ityp<0 .or. ityp>8) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid =(nlat+1)/2
        if ((ityp<=2 .and. idvw<nlat) .or. &
            (ityp>2 .and. idvw<imid)) return
        ierror = 6
        if (jdvw < nlon) return
        ierror = 7
        mmax = min(nlat, (nlon+1)/2)
        if (mdab < mmax) return
        ierror = 8
        if (ndab < nlat) return
        ierror = 9
        idz = (mmax*(nlat+nlat-mmax+1))/2
        lzimn = idz*imid
        if (lwvts < lzimn+lzimn+nlon+15) return
        ierror = 10
        idv = nlat
        if (ityp > 2) idv = imid
        lnl = nt*idv*nlon
        if (lwork < lnl+lnl+idv*nlon) return
        ierror = 0
        ist = 0
        if (ityp <= 2) ist = imid
        iw1 = ist+1
        iw2 = lnl+1
        iw3 = iw2+ist
        iw4 = iw2+lnl
        jw1 = lzimn+1
        jw2 = jw1+lzimn

        call vtses1(nlat, nlon, ityp, nt, imid, idvw, jdvw, vt, wt, mdab, ndab, &
            br, bi, cr, ci, idv, work, work(iw1), work(iw2), work(iw3), &
            work(iw4), idz, wvts, wvts(jw1), wvts(jw2))

    contains

        subroutine vtses1(nlat, nlon, ityp, nt, imid, idvw, jdvw, vt, wt, mdab, &
            ndab, br, bi, cr, ci, idv, vte, vto, wte, wto, work, idz, vb, wb, wrfft)

            real(wp) :: bi
            real(wp) :: br
            real(wp) :: ci
            real(wp) :: cr
            integer(ip) :: idv
            integer(ip) :: idvw
            integer(ip) :: idz
            integer(ip) :: imid
            integer(ip) :: imm1
            integer(ip) :: ityp
            integer(ip) :: jdvw
            integer(ip) :: m
            integer(ip) :: mb
            integer(ip) :: mdab
            integer(ip) :: mlat
            integer(ip) :: mlon
            integer(ip) :: mmax
            integer(ip) :: mn
            integer(ip) :: mp1
            integer(ip) :: mp2
            integer(ip) :: ndab
            integer(ip) :: ndo1
            integer(ip) :: ndo2
            integer(ip) :: nlat
            integer(ip) :: nlon
            integer(ip) :: nlp1
            integer(ip) :: np1
            integer(ip) :: nt
            real(wp) :: vb
            real(wp) :: vt
            real(wp) :: vte
            real(wp) :: vto
            real(wp) :: wb
            real(wp) :: work
            real(wp) :: wrfft
            real(wp) :: wt
            real(wp) :: wte
            real(wp) :: wto
            dimension vt(idvw, jdvw, 1), wt(idvw, jdvw, 1), br(mdab, ndab, 1), &
                bi(mdab, ndab, 1), cr(mdab, ndab, 1), ci(mdab, ndab, 1), &
                vte(idv, nlon, 1), vto(idv, nlon, 1), wte(idv, nlon, 1), &
                wto(idv, nlon, 1), work(1), wrfft(1), &
                vb(imid, 1), wb(imid, 1)

            integer(ip) :: i, j, k, hack_counter !! Counters

            type(HFFTpack) :: hfft

            nlp1 = nlat+1
            mlat = mod(nlat,2)
            mlon = mod(nlon,2)
            mmax = min(nlat,(nlon+1)/2)
            imm1 = imid
            if(mlat /= 0) imm1 = imid-1
            do k=1,nt
                do j=1,nlon
                    do i=1,idv
                        vte(i,j,k) = 0.
                        wte(i,j,k) = 0.
                    end do
                end do
            end do
            ndo1 = nlat
            ndo2 = nlat
            if(mlat /= 0) ndo1 = nlat-1
            if(mlat == 0) ndo2 = nlat-1

            select case (ityp)
                case (0)
                    goto 1
                case (1)
                    goto 100
                case (2)
                    goto 200
                case (3)
                    goto 300
                case (4)
                    goto 400
                case (5)
                    goto 500
                case (6)
                    goto 600
                case (7)
                    goto 700
                case (8)
                    goto 800
            end select
            !
            !     case ityp=0   no symmetries
            !
            !     case m = 0
            !
            1 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        vto(i,1,k)=vto(i,1,k)+br(1,np1,k)*vb(i,np1)
                        wto(i,1,k)=wto(i,1,k)-cr(1,np1,k)*vb(i,np1)
15                  continue
                    end do
                end do
            end do
            do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        vte(i,1,k)=vte(i,1,k)+br(1,np1,k)*vb(i,np1)
                        wte(i,1,k)=wte(i,1,k)-cr(1,np1,k)*vb(i,np1)
16                  continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 26
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
23                      continue
                        end do
                        if(mlat == 0) goto 24
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            +br(mp1,np1,k)*vb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +bi(mp1,np1,k)*vb(imid,mn)
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -cr(mp1,np1,k)*vb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            -ci(mp1,np1,k)*vb(imid,mn)
24                  continue
                    end do
25              continue
                end do
26              if(mp2 > ndo2) goto 30
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
27                      continue
                        end do
                        if(mlat == 0) goto 28
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            -ci(mp1,np1,k)*wb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +cr(mp1,np1,k)*wb(imid,mn)
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -bi(mp1,np1,k)*wb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            +br(mp1,np1,k)*wb(imid,mn)
28                  continue
                    end do
29              continue
                end do
30          continue
            end do
            goto 950
            !
            !     case ityp=1   no symmetries,  cr and ci equal zero
            !
            !     case m = 0
            !
            100 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        vto(i,1,k)=vto(i,1,k)+br(1,np1,k)*vb(i,np1)
115                 continue
                    end do
                end do
            end do
            do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        vte(i,1,k)=vte(i,1,k)+br(1,np1,k)*vb(i,np1)
116                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 126
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
123                     continue
                        end do
                        if(mlat == 0) goto 124
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            +br(mp1,np1,k)*vb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +bi(mp1,np1,k)*vb(imid,mn)
124                 continue
                    end do
125             continue
                end do
126             if(mp2 > ndo2) goto 130
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
127                     continue
                        end do
                        if(mlat == 0) goto 128
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -bi(mp1,np1,k)*wb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            +br(mp1,np1,k)*wb(imid,mn)
128                 continue
                    end do
129             continue
                end do
130         continue
            end do
            goto 950
            !
            !     case ityp=2   no symmetries,  br and bi are equal to zero
            !
            !     case m = 0
            !
            200 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        wto(i,1,k)=wto(i,1,k)-cr(1,np1,k)*vb(i,np1)
215                 continue
                    end do
                end do
            end do
            do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        wte(i,1,k)=wte(i,1,k)-cr(1,np1,k)*vb(i,np1)
216                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 226
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
223                     continue
                        end do
                        if(mlat == 0) goto 224
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -cr(mp1,np1,k)*vb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            -ci(mp1,np1,k)*vb(imid,mn)
224                 continue
                    end do
225             continue
                end do
226             if(mp2 > ndo2) goto 230
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
227                     continue
                        end do
                        if(mlat == 0) goto 228
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            -ci(mp1,np1,k)*wb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +cr(mp1,np1,k)*wb(imid,mn)
228                 continue
                    end do
229             continue
                end do
230         continue
            end do
            goto 950
            !
            !     case ityp=3   v odd,  w even
            !
            !     case m = 0
            !
            300 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        vto(i,1,k)=vto(i,1,k)+br(1,np1,k)*vb(i,np1)
315                 continue
                    end do
                end do
            end do
            do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        wte(i,1,k)=wte(i,1,k)-cr(1,np1,k)*vb(i,np1)
316                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 326
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
323                     continue
                        end do
                        if(mlat == 0) goto 324
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -cr(mp1,np1,k)*vb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            -ci(mp1,np1,k)*vb(imid,mn)
324                 continue
                    end do
325             continue
                end do
326             if(mp2 > ndo2) goto 330
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
327                     continue
                        end do
                        if(mlat == 0) goto 328
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -bi(mp1,np1,k)*wb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            +br(mp1,np1,k)*wb(imid,mn)
328                 continue
                    end do
329             continue
                end do
330         continue
            end do
            goto 950
            !
            !     case ityp=4   v odd,  w even, and both cr and ci equal zero
            !
            !     case m = 0
            !
            400 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        vto(i,1,k)=vto(i,1,k)+br(1,np1,k)*vb(i,np1)
415                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp2 > ndo2) goto 430
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
427                     continue
                        end do
                        if(mlat == 0) goto 428
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -bi(mp1,np1,k)*wb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            +br(mp1,np1,k)*wb(imid,mn)
428                 continue
                    end do
429             continue
                end do
430         continue
            end do
            goto 950
            !
            !     case ityp=5   v odd,  w even,     br and bi equal zero
            !
            !     case m = 0
            !
            500 do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        wte(i,1,k)=wte(i,1,k)-cr(1,np1,k)*vb(i,np1)
516                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 530
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vto(i,2*mp1-2,k) = vto(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vto(i,2*mp1-1,k) = vto(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wte(i,2*mp1-2,k) = wte(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wte(i,2*mp1-1,k) = wte(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
523                     continue
                        end do
                        if(mlat == 0) goto 524
                        wte(imid,2*mp1-2,k) = wte(imid,2*mp1-2,k) &
                            -cr(mp1,np1,k)*vb(imid,mn)
                        wte(imid,2*mp1-1,k) = wte(imid,2*mp1-1,k) &
                            -ci(mp1,np1,k)*vb(imid,mn)
524                 continue
                    end do
525             continue
                end do
530         continue
            end do
            goto 950
            !
            !     case ityp=6   v even  ,  w odd
            !
            !     case m = 0
            !
            600 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        wto(i,1,k)=wto(i,1,k)-cr(1,np1,k)*vb(i,np1)
615                 continue
                    end do
                end do
            end do
            do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        vte(i,1,k)=vte(i,1,k)+br(1,np1,k)*vb(i,np1)
616                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 626
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
623                     continue
                        end do
                        if(mlat == 0) goto 624
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            +br(mp1,np1,k)*vb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +bi(mp1,np1,k)*vb(imid,mn)
624                 continue
                    end do
625             continue
                end do
626             if(mp2 > ndo2) goto 630
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
627                     continue
                        end do
                        if(mlat == 0) goto 628
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            -ci(mp1,np1,k)*wb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +cr(mp1,np1,k)*wb(imid,mn)
628                 continue
                    end do
629             continue
                end do
630         continue
            end do
            goto 950
            !
            !     case ityp=7   v even, w odd   cr and ci equal zero
            !
            !     case m = 0
            !
            700 do k=1,nt
                do np1=3,ndo1,2
                    do i=1,imid
                        vte(i,1,k)=vte(i,1,k)+br(1,np1,k)*vb(i,np1)
716                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp1 > ndo1) goto 730
                do k=1,nt
                    do np1=mp1,ndo1,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)+br(mp1,np1,k)*vb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+bi(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-bi(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)+br(mp1,np1,k)*wb(i,mn)
723                     continue
                        end do
                        if(mlat == 0) goto 724
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            +br(mp1,np1,k)*vb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +bi(mp1,np1,k)*vb(imid,mn)
724                 continue
                    end do
725             continue
                end do
730         continue
            end do
            goto 950
            !
            !     case ityp=8   v even,  w odd,   br and bi equal zero
            !
            !     case m = 0
            !
            800 do k=1,nt
                do np1=2,ndo2,2
                    do i=1,imm1
                        wto(i,1,k)=wto(i,1,k)-cr(1,np1,k)*vb(i,np1)
815                 continue
                    end do
                end do
            end do
            !
            !     case m = 1 through nlat-1
            !
            if(mmax < 2) goto 950
            do mp1=2,mmax
                m = mp1-1
                mb = m*(nlat-1)-(m*(m-1))/2
                mp2 = mp1+1
                if(mp2 > ndo2) goto 830
                do k=1,nt
                    do np1=mp2,ndo2,2
                        mn = mb+np1
                        do i=1,imm1
                            vte(i,2*mp1-2,k) = vte(i,2*mp1-2,k)-ci(mp1,np1,k)*wb(i,mn)
                            vte(i,2*mp1-1,k) = vte(i,2*mp1-1,k)+cr(mp1,np1,k)*wb(i,mn)
                            wto(i,2*mp1-2,k) = wto(i,2*mp1-2,k)-cr(mp1,np1,k)*vb(i,mn)
                            wto(i,2*mp1-1,k) = wto(i,2*mp1-1,k)-ci(mp1,np1,k)*vb(i,mn)
827                     continue
                        end do
                        if(mlat == 0) goto 828
                        vte(imid,2*mp1-2,k) = vte(imid,2*mp1-2,k) &
                            -ci(mp1,np1,k)*wb(imid,mn)
                        vte(imid,2*mp1-1,k) = vte(imid,2*mp1-1,k) &
                            +cr(mp1,np1,k)*wb(imid,mn)
828                 continue
                    end do
829             continue
                end do
830         continue
            end do
            950 do k=1,nt
                call hfft%backward(idv,nlon,vte(1,1,k),idv,wrfft,work)
                call hfft%backward(idv,nlon,wte(1,1,k),idv,wrfft,work)
14          continue
            end do
            if(ityp > 2) goto 12
            do k=1,nt
                do j=1,nlon
                    do i=1,imm1
                        vt(i,j,k) = .5*(vte(i,j,k)+vto(i,j,k))
                        wt(i,j,k) = .5*(wte(i,j,k)+wto(i,j,k))
                        vt(nlp1-i,j,k) = .5*(vte(i,j,k)-vto(i,j,k))
                        wt(nlp1-i,j,k) = .5*(wte(i,j,k)-wto(i,j,k))
60                  continue
                    end do
                end do
            end do
            goto 13
            12 do k=1,nt
                do j=1,nlon
                    do i=1,imm1
                        vt(i,j,k) = .5*vte(i,j,k)
                        wt(i,j,k) = .5*wte(i,j,k)
11                  continue
                    end do
                end do
            end do
13          if(mlat == 0) return
            do k=1,nt
                do j=1,nlon
                    vt(imid,j,k) = .5*vte(imid,j,k)
                    wt(imid,j,k) = .5*wte(imid,j,k)
65              continue
                end do
            end do

        end subroutine vtses1

    end subroutine vtses

    subroutine vtsesi(nlat, nlon, wvts, lwvts, work, lwork, dwork, ldwork, &
        ierror)

        integer(ip) :: idz
        integer(ip) :: ierror
        integer(ip) :: imid
        integer(ip) :: iw1
        integer(ip) :: labc
        integer(ip) :: ldwork
        integer(ip) :: lwork
        integer(ip) :: lwvts
        integer(ip) :: lzimn
        integer(ip) :: mmax
        integer(ip) :: nlat
        integer(ip) :: nlon
        real(wp) :: wvts(lwvts), work(lwork)
        real(wp) :: dwork(ldwork)

        type(HFFTpack) :: hfft

        ierror = 1
        if(nlat < 3) return
        ierror = 2
        if (nlon < 1) return
        ierror = 3
        mmax = min(nlat, (nlon+1)/2)
        imid =(nlat+1)/2
        lzimn = (imid*mmax*(nlat+nlat-mmax+1))/2
        if (lwvts < lzimn+lzimn+nlon+15) return
        ierror = 4
        labc = 3*(max(mmax-2, 0)*(nlat+nlat-mmax-1))/2
        if (lwork < 5*nlat*imid+labc) return
        ierror = 5
        if (ldwork < 2*(nlat+1)) return
        ierror = 0
        iw1 = 3*nlat*imid+1
        idz = (mmax*(nlat+nlat-mmax+1))/2

        call vet1(nlat, nlon, imid, wvts, wvts(lzimn+1), idz, work, work(iw1), dwork)

        call hfft%initialize(nlon, wvts(2*lzimn+1))

    contains

        subroutine vet1(nlat, nlon, imid, vb, wb, idz, vin, wzvin, dwork)
            integer(ip) :: i3
            integer(ip) :: idz
            integer(ip) :: imid
            integer(ip) :: m, mmax
            integer(ip) :: mn
            integer(ip) :: mp1
            integer(ip) :: nlat
            integer(ip) :: nlon
            integer(ip) :: np1
            real(wp) :: vb
            real(wp) :: vin
            real(wp) :: wb
            real(wp) :: wzvin
            dimension vb(imid, *), wb(imid, *), vin(imid, nlat, 3), wzvin(*)
            real dwork(*)

            type(SpherepackAux) :: sphere_aux

            mmax = min(nlat, (nlon+1)/2)

            call sphere_aux%vtinit(nlat, nlon, wzvin, dwork)

            do mp1=1, mmax
                m = mp1-1
                call sphere_aux%vbin(0, nlat, nlon, m, vin, i3, wzvin)
                do np1=mp1, nlat
                    mn = m*(nlat-1)-(m*(m-1))/2+np1
                    vb(1:imid, mn) = vin(1:imid, np1, i3)
                end do
            end do

            call sphere_aux%wtinit(nlat, nlon, wzvin, dwork)

            do mp1=1, mmax
                m = mp1-1
                call sphere_aux%wbin(0, nlat, nlon, m, vin, i3, wzvin)
                do np1=mp1, nlat
                    mn = m*(nlat-1)-(m*(m-1))/2+np1
                    wb(1:imid, mn) = vin(1:imid, np1, i3)
                end do
            end do

        end subroutine vet1

    end subroutine vtsesi

end module module_vtses
