module type_RegularWorkspace

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use type_Workspace, only: &
        Workspace

    use scalar_analysis_routines, only: &
        ShaesAux

    use scalar_synthesis_routines, only: &
        ShsesAux

    use vector_analysis_routines, only: &
        VhaesAux

    use vector_synthesis_routines, only: &
        VhsesAux

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: RegularWorkspace


    
    type, extends(Workspace), public :: RegularWorkspace
    contains
        !----------------------------------------------------------------------
        ! Type-bound procedures
        !----------------------------------------------------------------------
        procedure, public  :: create => create_regular_workspace
        procedure, public  :: destroy => destroy_regular_workspace
        procedure, private :: initialize_regular_scalar_analysis
        procedure, private :: initialize_regular_scalar_synthesis
        procedure, private :: initialize_regular_scalar_transform
        procedure, private :: initialize_regular_vector_analysis
        procedure, private :: initialize_regular_vector_synthesis
        procedure, private :: initialize_regular_vector_transform
        procedure, private :: copy_regular_workspace
        final              :: finalize_regular_workspace
        !----------------------------------------------------------------------
        ! Generic type-bound procedures
        !----------------------------------------------------------------------
        generic, public :: assignment (=) => copy_regular_workspace
        !----------------------------------------------------------------------
    end type RegularWorkspace

    ! Declare constructor
    interface RegularWorkspace
        module procedure regular_workspace_constructor
    end interface

contains

    function regular_workspace_constructor(nlat, nlon) result (return_value)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        integer(ip), intent(in) :: nlat !! number of latitudinal points 0 <= theta <= pi
        integer(ip), intent(in) :: nlon !! number of longitudinal points 0 <= phi <= 2*pi
        type(RegularWorkspace)   :: return_value
        !----------------------------------------------------------------------

        call return_value%create(nlat, nlon)

    end function regular_workspace_constructor


    subroutine copy_regular_workspace(self, object_to_be_copied)
        !--------------------------------------------------------------------------------
        ! Dummy arguments
        !--------------------------------------------------------------------------------
        class(RegularWorkspace), intent(out) :: self
        class(RegularWorkspace), intent(in)  :: object_to_be_copied
        !--------------------------------------------------------------------------------

        ! Check if object is usable
        if (.not.object_to_be_copied%initialized) then
            error stop 'Uninitialized object of class(RegularWorkspace): '&
                //'in assignment (=) '
        end if

        !
        !  Make copies
        !
        self%initialized = object_to_be_copied%initialized
        self%legendre_workspace = object_to_be_copied%legendre_workspace
        self%forward_scalar = object_to_be_copied%forward_scalar
        self%forward_vector = object_to_be_copied%forward_vector
        self%backward_scalar = object_to_be_copied%backward_scalar
        self%backward_vector = object_to_be_copied%backward_vector
        self%real_harmonic_coefficients = object_to_be_copied%real_harmonic_coefficients
        self%imaginary_harmonic_coefficients = object_to_be_copied%imaginary_harmonic_coefficients
        self%real_polar_harmonic_coefficients = object_to_be_copied%real_polar_harmonic_coefficients
        self%imaginary_polar_harmonic_coefficients = object_to_be_copied%imaginary_polar_harmonic_coefficients
        self%real_azimuthal_harmonic_coefficients = object_to_be_copied%real_azimuthal_harmonic_coefficients
        self%imaginary_azimuthal_harmonic_coefficients = object_to_be_copied%imaginary_azimuthal_harmonic_coefficients


    end subroutine copy_regular_workspace



    subroutine create_regular_workspace(self, nlat, nlon)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------

        ! Ensure that object is usable
        call self%destroy()

        ! Set up transforms for regular grids
        call self%initialize_regular_scalar_transform(nlat, nlon)
        call self%initialize_regular_vector_transform(nlat, nlon)
        call get_legendre_workspace(nlat, nlon, self%legendre_workspace)

        ! Set flag
        self%initialized = .true.

    end subroutine create_regular_workspace



    subroutine destroy_regular_workspace(self)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        !----------------------------------------------------------------------

        ! Check flag
        if (.not.self%initialized) return

        ! Release memory from parent type
        call self%destroy_workspace()

        ! Reset flag
        self%initialized = .false.

    end subroutine destroy_regular_workspace



    subroutine initialize_regular_scalar_analysis(self, nlat, nlon)
        !
        ! Purpose:
        !
        !  Set the various workspace arrays to perform the
        !  (real) scalar harmonic analysis on a regular (equally-spaced) grid.
        !
        !  Reference:
        !  https://www2.cisl.ucar.edu/spherepack/documentation#shaesi.html
        !
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        integer(ip)           :: error_flag
        integer(ip)           :: lwork, ldwork, lshaes
        real(wp), allocatable :: dwork(:), work(:)
        type(ShaesAux)        :: aux
        !----------------------------------------------------------------------

        !
        !  Compute dimensions of various workspace arrays
        !
        lwork = get_lwork(nlat, nlon)
        ldwork = get_ldwork(nlat)
        lshaes = aux%get_lshaes(nlat, nlon)

        !
        !   Allocate memory
        !
        if (allocated(self%forward_scalar)) deallocate( self%forward_scalar )
        allocate( work(lwork) )
        allocate( dwork(ldwork) )
        allocate( self%forward_scalar(lshaes) )


        associate( &
            wshaes => self%forward_scalar, &
            ierror => error_flag &
            )
            !
            !  Initialize workspace for scalar synthesis
            !
            call aux%shaesi(nlat, nlon, wshaes, lshaes, work, lwork, dwork, ldwork, ierror)

        end associate

        !
        !   Address error flag
        !
        select case (error_flag)
            case(0)
                return
            case(1)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_analysis '&
                    //'error in the specification of NUMBER_OF_LATITUDES'
            case(2)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_analysis '&
                    //'error in the specification of NUMBER_OF_LONGITUDES'
            case(3)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_analysis '&
                    //'error in the specification of extent for forward_scalar'
            case(4)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_analysis '&
                    //'error in the specification of extent for legendre_workspace'
            case default
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_analysis '&
                    //'Undetermined error flag'
        end select

        !
        !  Release memory
        !
        deallocate( work )
        deallocate( dwork )

    end subroutine initialize_regular_scalar_analysis



    subroutine initialize_regular_scalar_synthesis(self, nlat, nlon)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        integer(ip)           :: error_flag
        integer(ip)           :: lwork, ldwork, lshses
        real(wp), allocatable :: dwork(:), work(:)
        type(ShsesAux)        :: aux
        !----------------------------------------------------------------------

        ! Set up various workspace dimensions
        lwork = get_lwork(nlat, nlon)
        ldwork = get_ldwork(nlat)
        lshses = aux%get_lshses(nlat, nlon)

        !
        !  Allocate memory
        !
        if (allocated(self%backward_scalar)) deallocate( self%backward_scalar )
        allocate( self%backward_scalar(lshses) )
        allocate( work(lwork) )
        allocate( dwork(ldwork) )


        associate( &
            wshses => self%backward_scalar, &
            ierror => error_flag &
            )
            !
            !  Initialize workspace for scalar synthesis
            !
            call aux%shsesi(nlat, nlon, wshses, lshses, work, lwork, dwork, ldwork, ierror)

        end associate


        !  Address error flag
        select case (error_flag)
            case(0)
                return
            case(1)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_synthesis '&
                    //'error in the specification of NUMBER_OF_LATITUDES'
            case(2)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_synthesis '&
                    //'error in the specification of NUMBER_OF_LONGITUDES'
            case(3)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_synthesis '&
                    //'error in the specification of extent for forward_scalar'
            case(4)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_synthesis '&
                    //'error in the specification of extent for legendre_workspace'
            case default
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_scalar_synthesis '&
                    //'Undetermined error flag'
        end select

        !
        !  Release memory
        !
        deallocate( work )
        deallocate( dwork )

    end subroutine initialize_regular_scalar_synthesis



    subroutine initialize_regular_scalar_transform(self, nlat, nlon)
        !
        ! Purpose:
        !
        !  Set the various workspace arrays and pointers to perform the
        !  (real) scalar harmonic transform on a regular (equally-spaced) grid.
        !
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------

        ! Set up scalar analysis
        call self%initialize_regular_scalar_analysis(nlat, nlon)

        ! Set up scalar synthesis
        call self%initialize_regular_scalar_synthesis(nlat, nlon)

        ! Allocate memory for the (real) scalar harmonic transform
        allocate( self%real_harmonic_coefficients(nlat, nlat) )
        allocate( self%imaginary_harmonic_coefficients(nlat, nlat) )

    end subroutine initialize_regular_scalar_transform



    subroutine initialize_regular_vector_analysis(self, nlat, nlon)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        integer(ip)           :: error_flag
        integer(ip)           :: lwork, ldwork, lvhaes
        real(wp), allocatable :: work(:), dwork(:)
        type(VhaesAux)        :: aux
        !----------------------------------------------------------------------

        ! Compute various workspace dimensions
        lwork = get_lwork(nlat, nlon)
        ldwork = get_ldwork(nlat)
        lvhaes = aux%get_lvhaes(nlat, nlon)

        !
        !  Allocate memory
        !
        if (allocated(self%forward_vector)) deallocate( self%forward_vector )
        allocate( work(lwork) )
        allocate( dwork(ldwork) )
        allocate( self%forward_vector(lvhaes) )


        associate( &
            wvhaes => self%forward_vector, &
            ierror => error_flag &
            )
            !
            !  Initialize workspace for analysis
            !
            call aux%vhaesi(nlat, nlon, wvhaes, lvhaes, work, lwork, dwork, ldwork, ierror)

        end associate

        ! Address the error flag
        select case (error_flag)
            case(0)
                return
            case(1)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //'error in the specification of NUMBER_OF_LATITUDES'
            case(2)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //'error in the specification of NUMBER_OF_LONGITUDES'
            case(3)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //'error in the specification of extent for forward_vector'
            case(4)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //'error in the specification of extent for unsaved work'
            case(5)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //'error in the specification of extent for unsaved dwork'
            case default
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_analysis'&
                    //' Undetermined error flag'
        end select

        !
        !  Release memory
        !
        deallocate( work )
        deallocate( dwork )

    end subroutine initialize_regular_vector_analysis



    subroutine initialize_regular_vector_synthesis(self, nlat, nlon)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        integer(ip)           :: error_flag
        integer(ip)           :: lwork, ldwork, lvhses
        real(wp), allocatable :: work(:), dwork(:)
        type(VhsesAux)        :: aux
        !----------------------------------------------------------------------

        ! Compute various workspace dimensions
        lwork = get_lwork(nlat, nlon)
        ldwork = get_ldwork(nlat)
        lvhses = aux%get_lvhses(nlat, nlon)

        !
        !  Allocate memory
        !
        if (allocated(self%backward_vector)) deallocate( self%backward_vector )
        allocate( work(lwork) )
        allocate( dwork(ldwork) )
        allocate( self%backward_vector(lvhses) )

        associate( &
            wvhses => self%backward_vector, &
            ierror => error_flag &
            )

            !
            !  Initialize workspace for vector synthesis
            !
            call aux%vhsesi(nlat, nlon, wvhses, lvhses, work, lwork, dwork, ldwork, ierror)

        end associate

        ! Address the error flag
        select case (error_flag)
            case(0)
                return
            case(1)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis '&
                    //'error in the specification of NUMBER_OF_LATITUDES'
            case(2)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis '&
                    //'error in the specification of NUMBER_OF_LONGITUDES'
            case(3)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis '&
                    //'error in the specification of extent for backward_vector'
            case(4)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis'&
                    //'error in the specification of extent for unsaved work'
            case(5)
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis '&
                    //'error in the specification of extent for unsaved dwork'
            case default
                error stop 'Object of class(RegularWorkspace): '&
                    //'in initialize_regular_vector_synthesis'&
                    //' Undetermined error flag'
        end select

        !
        !  Release memory
        !
        deallocate( work )
        deallocate( dwork )

    end subroutine initialize_regular_vector_synthesis



    subroutine initialize_regular_vector_transform(self, nlat, nlon)
        !
        ! Purpose:
        !
        ! Sets the various workspace arrays and pointers
        ! required for the (real) vector harmonic transform
        ! on a regular (equally-spaced) grid
        !
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(RegularWorkspace), intent(inout)  :: self
        integer(ip),             intent(in)     :: nlat
        integer(ip),             intent(in)     :: nlon
        !----------------------------------------------------------------------

        ! Set up vector analysis
        call self%initialize_regular_vector_analysis(nlat, nlon)

        ! Set up vector synthesis
        call self%initialize_regular_vector_synthesis(nlat, nlon)

        ! Allocate memory for the vector transform coefficients
        allocate( self%real_polar_harmonic_coefficients(nlat, nlat) )
        allocate( self%imaginary_polar_harmonic_coefficients(nlat, nlat) )
        allocate( self%real_azimuthal_harmonic_coefficients(nlat, nlat) )
        allocate( self%imaginary_azimuthal_harmonic_coefficients(nlat, nlat) )

    end subroutine initialize_regular_vector_transform



    pure function get_lwork(nlat, nlon) result (return_value)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        integer(ip), intent(in)  :: nlat
        integer(ip), intent(in)  :: nlon
        integer(ip)               :: return_value
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type(ShaesAux) :: shaes_aux
        type(ShsesAux) :: shses_aux
        type(VhaesAux) :: vhaes_aux
        type(VhsesAux) :: vhses_aux
        integer(ip)    :: lwork(4)
        !----------------------------------------------------------------------

        lwork(1) = shaes_aux%get_lwork(nlat, nlon)
        lwork(2) = shses_aux%get_lwork(nlat, nlon)
        lwork(3) = vhaes_aux%get_lwork(nlat, nlon)
        lwork(4) = vhses_aux%get_lwork(nlat, nlon)

        return_value = maxval(lwork)

    end function get_lwork


    pure function get_ldwork(nlat) result (return_value)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        integer(ip), intent(in)  :: nlat
        integer(ip)               :: return_value
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type(ShaesAux) :: shaes_aux
        type(ShsesAux) :: shses_aux
        type(VhaesAux) :: vhaes_aux
        type(VhsesAux) :: vhses_aux
        integer(ip)    :: ldwork(4)
        !----------------------------------------------------------------------

        ldwork(1) = shaes_aux%get_ldwork(nlat)
        ldwork(2) = shses_aux%get_ldwork(nlat)
        ldwork(3) = vhaes_aux%get_ldwork(nlat)
        ldwork(4) = vhses_aux%get_ldwork(nlat)

        return_value = maxval(ldwork)

    end function get_ldwork



    pure subroutine get_legendre_workspace(nlat, nlon, workspace, nt, ityp)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        integer(ip),           intent(in)  :: nlat
        integer(ip),           intent(in)  :: nlon
        real(wp), allocatable, intent(out) :: workspace(:)
        integer(ip), optional, intent(in)  :: nt
        integer(ip), optional, intent(in)  :: ityp
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type(ShaesAux) :: shaes_aux
        type(ShsesAux) :: shses_aux
        type(VhaesAux) :: vhaes_aux
        type(VhsesAux) :: vhses_aux
        integer(ip)    :: work_size(4)
        integer(ip)    :: lwork, nt_op, ityp_op
        !----------------------------------------------------------------------

        !
        !  Address optional arguments
        !
        if (present(nt)) then
            nt_op = nt
        else
            nt_op = 1
        end if

        if (present(ityp)) then
            ityp_op = ityp
        else
            ityp_op = 0
        end if

        work_size(1) = shaes_aux%get_legendre_workspace_size(nlat, nlon, nt_op, ityp_op)
        work_size(2) = shses_aux%get_legendre_workspace_size(nlat, nlon, nt_op, ityp_op)
        work_size(3) = vhaes_aux%get_legendre_workspace_size(nlat, nlon, nt_op, ityp_op)
        work_size(4) = vhses_aux%get_legendre_workspace_size(nlat, nlon, nt_op, ityp_op)

        lwork = maxval(work_size)
        !
        !  Allocate memory
        !
        allocate( workspace(lwork) )

    end subroutine get_legendre_workspace



    subroutine finalize_regular_workspace(self)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        type(RegularWorkspace), intent(inout)  :: self
        !----------------------------------------------------------------------

        call self%destroy_workspace()

    end subroutine finalize_regular_workspace



end module type_RegularWorkspace
