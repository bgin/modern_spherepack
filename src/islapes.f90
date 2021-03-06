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
! ... file islapes.f
!
!     this file includes documentation and code for
!     subroutine islapes         i
!
! ... files which must be loaded with islapes.f
!
!     type_SpherepackAux.f, type_HFFTpack.f, shaes.f, shses.f
!
!     subroutine islapes(nlat, nlon, isym, nt, xlmbda, sf, ids, jds, a, b, 
!    +mdab, ndab, wshses, lshses, work, lwork, pertrb, ierror)
!
!     islapes inverts the laplace or helmholz operator on an equally
!     spaced latitudinal grid using o(n**3) storage. given the
!     spherical harmonic coefficients a(m, n) and b(m, n) of the right
!     hand side slap(i, j), islapes computes a solution sf(i, j) to
!     the following helmhotz equation :
!
!           2                2
!     [d(sf(i, j))/dlambda /sint + d(sint*d(sf(i, j))/dtheta)/dtheta]/sint
!
!                   - xlmbda * sf(i, j) = slap(i, j)
!
!      where sf(i, j) is computed at colatitude
!
!                 theta(i) = (i-1)*pi/(nlat-1)
!
!            and longitude
!
!                 lambda(j) = (j-1)*2*pi/nlon
!
!            for i=1, ..., nlat and j=1, ..., nlon.
!
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
!            nlat/2 if nlat is even or (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct longitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     isym   this parameter should have the same value input to subroutine
!            shaes to compute the coefficients a and b for the scalar field
!            slap.  isym is set as follows:
!
!            = 0  no symmetries exist in slap about the equator. scalar
!                 synthesis is used to compute sf on the entire sphere.
!                 i.e., in the array sf(i, j) for i=1, ..., nlat and
!                 j=1, ..., nlon.
!
!           = 1  sf and slap are antisymmetric about the equator. the
!                synthesis used to compute sf is performed on the
!                northern hemisphere only.  if nlat is odd, sf(i, j) is
!                computed for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if
!                nlat is even, sf(i, j) is computed for i=1, ..., nlat/2
!                and j=1, ..., nlon.
!
!
!           = 2  sf and slap are symmetric about the equator. the
!                synthesis used to compute sf is performed on the
!                northern hemisphere only.  if nlat is odd, sf(i, j) is
!                computed for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if
!                nlat is even, sf(i, j) is computed for i=1, ..., nlat/2
!                and j=1, ..., nlon.
!
!
!   nt       the number of solutions. in the program that calls islapes
!            the arrays sf, a, and b can be three dimensional in which
!            case multiple solutions are computed. the third index
!            is the solution index with values k=1, ..., nt.
!            for a single solution set nt=1. the description of the
!            remaining parameters is simplified by assuming that nt=1
!            and sf, a, b are two dimensional.
!
!   xlmbda   a one dimensional array with nt elements. if xlmbda is
!            is identically zero islapes solves poisson's equation.
!            if xlmbda > 0.0 islapes solves the helmholtz equation.
!            if xlmbda < 0.0 the nonfatal error flag ierror=-1 is
!            returned. negative xlambda could result in a division
!            by zero.
!
!   ids      the first dimension of the array sf as it appears in the
!            program that calls islapes.  if isym = 0 then ids must be at
!            least nlat.  if isym > 0 and nlat is even then ids must be
!            at least nlat/2. if isym > 0 and nlat is odd then ids must
!            be at least (nlat+1)/2.
!
!   jds      the second dimension of the array sf as it appears in the
!            program that calls islapes. jds must be at least nlon.
!
!
!   a, b      two or three dimensional arrays (see input parameter nt)
!            that contain scalar spherical harmonic coefficients
!            of the scalar field slap. a, b must be computed by shaes
!            prior to calling islapes.
!
!
!   mdab     the first dimension of the arrays a and b as it appears
!            in the program that calls islapes.  mdab must be at
!            least min(nlat, (nlon+2)/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!   ndab     the second dimension of the arrays a and b as it appears
!            in the program that calls islapes. ndbc must be at least
!            least nlat.
!
!            mdab, ndab should have the same values input to shaes to
!            compute the coefficients a and b.
!
!
!   wshses   an array which must be initialized by subroutine shsesi.
!            once initialized, wshses can be used repeatedly by
!            islapes as long as nlat and nlon  remain unchanged.
!            wshses must not be altered between calls of islapes.
!
!    lshses  the dimension of the array wshses as it appears in the
!            program that calls islapes.  let
!
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lshses must be at least
!
!               (l1*l2*(nlat+nlat-l1+1))/2+nlon+15
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls islapes. define
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            if isym is zero then lwork must be at least
!
!               (nt+1)*nlat*nlon + nlat*(2*nt*l1+1)
!
!            if isym is nonzero lwork must be at least
!
!               (nt+1)*l2*nlon + nlat*(2*nt*l1+1)
!
!
!     **************************************************************
!
!     output parameters
!
!
!    sf      a two or three dimensional arrays (see input parameter nt) that
!            inverts the scalar laplacian in slap - pertrb.  sf(i, j) is given
!            at the colatitude
!
!                 theta(i) = (i-1)*pi/(nlat-1)
!
!            and longitude
!
!                 lambda(j) = (j-1)*2*pi/nlon
!
!            for i=1, ..., nlat and j=1, ..., nlon.
!
!   pertrb  a one dimensional array with nt elements (see input 
!           parameter nt). in the discription that follows we assume 
!           that nt=1. if xlmbda > 0.0 then pertrb=0.0 is always 
!           returned because the helmholtz operator is invertible.
!           if xlmbda = 0.0 then a solution exists only if a(1, 1)
!           is zero. islapec sets a(1, 1) to zero. the resulting
!           solution sf(i, j) solves poisson's equation with
!           pertrb = a(1, 1)/(2.*sqrt(2.)) subtracted from the
!           right side slap(i, j).
!
!  ierror    a parameter which flags errors in input parameters as follows:
!
!            = 0  no errors detected
!
!            = 1  error in the specification of nlat
!
!            = 2  error in the specification of nlon
!
!            = 3  error in the specification of ityp
!
!            = 4  error in the specification of nt
!
!            = 5  error in the specification of ids
!
!            = 6  error in the specification of jds
!
!            = 7  error in the specification of mdbc
!
!            = 8  error in the specification of ndbc
!
!            = 9  error in the specification of lshses
!
!            = 10 error in the specification of lwork
!
!
! **********************************************************************
!                                                                              
!     end of documentation for islapes
!
! **********************************************************************
!
module module_islapes

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use scalar_synthesis_routines, only: &
        shses

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: islapes

contains

    subroutine islapes(nlat, nlon, isym, nt, xlmbda, sf, ids, jds, a, b, &
        mdab, ndab, wshses, lshses, work, lwork, pertrb, ierror)

        real(wp) :: a
        real(wp) :: b
        integer(ip) :: ia
        integer(ip) :: ib
        integer(ip) :: ids
        integer(ip) :: ierror
        integer(ip) :: ifn
        integer(ip) :: imid
        integer(ip) :: isym
        integer(ip) :: iwk
        integer(ip) :: jds
        integer(ip) :: k
        integer(ip) :: l1
        integer(ip) :: l2
        integer(ip) :: lpimn
        integer(ip) :: ls
        integer(ip) :: lshses
        integer(ip) :: lwk
        integer(ip) :: lwkmin
        integer(ip) :: lwork
        integer(ip) :: mdab
        integer(ip) :: mmax
        integer(ip) :: mn
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nln
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: pertrb
        real(wp) :: sf
        real(wp) :: work
        real(wp) :: wshses
        real(wp) :: xlmbda
        dimension sf(ids, jds, nt), a(mdab, ndab, nt), b(mdab, ndab, nt)
        dimension wshses(lshses), work(lwork), xlmbda(nt), pertrb(nt)
        !
        !     check input parameters
        !
        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 4) return
        ierror = 3
        if (isym < 0 .or. isym > 2) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid = (nlat+1)/2
        if ((isym == 0 .and. ids<nlat) .or. &
            (isym>0 .and. ids<imid)) return
        ierror = 6
        if (jds < nlon) return
        ierror = 7
        mmax = min(nlat, nlon/2+1)
        if (mdab < mmax) return
        ierror = 8
        if (ndab < nlat) return
        ierror = 9
        !
        !     set and verify saved work space length
        !
        imid = (nlat+1)/2
        lpimn = (imid*mmax*(nlat+nlat-mmax+1))/2
        if (lshses < lpimn+nlon+15) return
        ierror = 10
        !
        !     set and verify unsaved work space length
        !
        ls = nlat
        if (isym > 0) ls = imid
        nln = nt*ls*nlon
        mn = mmax*nlat*nt
        !     lwkmin = nln+ls*nlon+2*mn+nlat
        !     if (lwork .lt. lwkmin) return
        l2 = (nlat+1)/2
        l1 = min(nlat, nlon/2+1)
        if (isym == 0) then
            lwkmin = (nt+1)*nlat*nlon + nlat*(2*nt*l1+1)
        else
            lwkmin = (nt+1)*l2*nlon + nlat*(2*nt*l1+1)
        end if
        if (lwork < lwkmin) return
        ierror = 0
        !
        !     check sign of xlmbda
        !
        do  k=1, nt
            if (xlmbda(k) < 0.0) then
                ierror = -1
            end if
        end do
        !
        !     set work space pointers
        !
        ia = 1
        ib = ia+mn
        ifn = ib+mn
        iwk = ifn+nlat
        lwk = lwork-2*mn-nlat

        call islpes1(nlat, nlon, isym, nt, xlmbda, sf, ids, jds, a, b, mdab, ndab, &
            work(ia), work(ib), mmax, work(ifn), wshses, lshses, work(iwk), lwk, &
            pertrb, ierror)

    contains

        subroutine islpes1(nlat, nlon, isym, nt, xlmbda, sf, ids, jds, a, b, &
            mdab, ndab, as, bs, mmax, fnn, wshses, lshses, wk, lwk, pertrb, ierror)

            real(wp) :: a
            real(wp) :: as
            real(wp) :: b
            real(wp) :: bs
            real(wp) :: fn
            real(wp) :: fnn
            integer(ip) :: ids
            integer(ip) :: ierror
            integer(ip) :: isym
            integer(ip) :: jds
            integer(ip) :: k
            integer(ip) :: lshses
            integer(ip) :: lwk
            integer(ip) :: m
            integer(ip) :: mdab
            integer(ip) :: mmax
            integer(ip) :: n
            integer(ip) :: ndab
            integer(ip) :: nlat
            integer(ip) :: nlon
            integer(ip) :: nt
            real(wp) :: pertrb
            real(wp) :: sf
            real(wp) :: wk
            real(wp) :: wshses
            real(wp) :: xlmbda
            dimension sf(ids, jds, nt), a(mdab, ndab, nt), b(mdab, ndab, nt)
            dimension as(mmax, nlat, nt), bs(mmax, nlat, nt), fnn(nlat)
            dimension wshses(lshses), wk(lwk), pertrb(nt), xlmbda(nt)
            !
            !     set multipliers and preset synthesis coefficients to zero
            !
            do n=1, nlat
                fn = real(n - 1)
                fnn(n) = fn*(fn+1.0)
                do m=1, mmax
                    do k=1, nt
                        as(m, n, k) = 0.0
                        bs(m, n, k) = 0.0
                    end do
                end do
            end do
            do k=1, nt
                    !
                    !     compute synthesis coefficients for xlmbda zero or nonzero
                    !
                if (xlmbda(k) == 0.0) then
                    do n=2, nlat
                        as(1, n, k) = -a(1, n, k)/fnn(n)
                        bs(1, n, k) = -b(1, n, k)/fnn(n)
                    end do
                    do m=2, mmax
                        do n=m, nlat
                            as(m, n, k) = -a(m, n, k)/fnn(n)
                            bs(m, n, k) = -b(m, n, k)/fnn(n)
                        end do
                    end do
                else
                    !
                    !     xlmbda nonzero so operator invertible unless
                    !     -n*(n-1) = xlmbda(k) < 0.0  for some n
                    !
                    pertrb(k) = 0.0
                    do n=1, nlat
                        as(1, n, k) = -a(1, n, k)/(fnn(n)+xlmbda(k))
                        bs(1, n, k) = -b(1, n, k)/(fnn(n)+xlmbda(k))
                    end do
                    do m=2, mmax
                        do n=m, nlat
                            as(m, n, k) = -a(m, n, k)/(fnn(n)+xlmbda(k))
                            bs(m, n, k) = -b(m, n, k)/(fnn(n)+xlmbda(k))
                        end do
                    end do
                end if
            end do
            !
            !     synthesize as, bs into sf
            !
            call shses(nlat, nlon, isym, nt, sf, ids, jds, as, bs, mmax, nlat, &
                wshses, lshses, wk, lwk, ierror)

        end subroutine islpes1

    end subroutine islapes

end module module_islapes
