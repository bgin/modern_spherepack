module type_TrigonometricFunctions

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use type_SphericalGrid, only: &
        SphericalGrid

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: TrigonometricFunctions

    
    type, public :: TrigonometricFunctions
        !----------------------------------------------------------------------
        ! Type components
        !----------------------------------------------------------------------
        logical,                public :: initialized = .false. !! Initialization flag
        integer(ip),           public :: NUMBER_OF_LONGITUDES = 0 !! number of longitudinal points in phi
        integer(ip),           public :: NUMBER_OF_LATITUDES = 0 !! number of latitudinal points in theta
        real(wp), allocatable, public :: sint(:)  !! sin(theta): 0 <= theta <= pi
        real(wp), allocatable, public :: cost(:)  !! cos(theta): 0 <= theta <= pi
        real(wp), allocatable, public :: sinp(:)  !! sin(phi):   0 <=  phi  <= 2*pi
        real(wp), allocatable, public :: cosp(:)  !! cos(phi):   0 <=  phi  <= 2*pi
        !----------------------------------------------------------------------
    contains
        !----------------------------------------------------------------------
        ! Type-bound procedures
        !----------------------------------------------------------------------
        procedure, public :: create => create_trigonometric_functions
        procedure, public :: destroy => destroy_trigonometric_functions
        final             :: finalize_trigonometric_functions
        !----------------------------------------------------------------------
    end type TrigonometricFunctions


    ! Declare constructor
    interface TrigonometricFunctions
        module procedure trigonometric_functions_constructor
    end interface



contains



    function trigonometric_functions_constructor(grid) result (return_value)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(SphericalGrid), intent(inout)  :: grid
        type(TrigonometricFunctions)          :: return_value
        !----------------------------------------------------------------------

        call return_value%create(grid)

    end function trigonometric_functions_constructor



    subroutine create_trigonometric_functions(self, grid_type)
        !
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(TrigonometricFunctions), intent(inout)  :: self
        class(SphericalGrid),          intent(in)     :: grid_type
        !----------------------------------------------------------------------

        ! Ensure that object is usable
        call self%destroy()

        ! Check if polymorphic argument is usable
        if ( grid_type%initialized .eqv. .false.) then
            error stop 'Object of class(TrigonometricFunctions): '&
                //'initialized polymorphic argument of class(SphericalGrid) '&
                //'in create_trigonometric_functions'
        end if

        ! Allocate memory
        associate( &
            nlat => grid_type%NUMBER_OF_LATITUDES, &
            nlon => grid_type%NUMBER_OF_LONGITUDES &
            )

            ! Set contants
            self%NUMBER_OF_LATITUDES = nlat
            self%NUMBER_OF_LONGITUDES = nlon

            allocate(self%sint(nlat) )
            allocate(self%cost(nlat) )
            allocate(self%sinp(nlon) )
            allocate(self%cosp(nlon) )
        end associate

        ! compute trigonometric functions
        associate( &
            theta => grid_type%latitudes, &
            phi => grid_type%longitudes, &
            sint => self%sint, &
            cost => self%cost, &
            sinp => self%sinp, &
            cosp => self%cosp &
            )

            sint = sin(theta)
            cost = cos(theta)
            sinp = sin(phi)
            cosp = cos(phi)

        end associate

        ! Set flag
        self%initialized = .true.

    end subroutine create_trigonometric_functions



    subroutine destroy_trigonometric_functions(self)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        class(TrigonometricFunctions), intent(inout)  :: self
        !----------------------------------------------------------------------

        ! Check flag
        if (.not.self%initialized) return

        ! Release memory
        if (allocated(self%sint)) deallocate(self%sint)
        if (allocated(self%cost)) deallocate(self%cost)
        if (allocated(self%sinp)) deallocate(self%sinp)
        if (allocated(self%cosp)) deallocate(self%cosp)

        ! Reset constants
        self%NUMBER_OF_LONGITUDES = 0
        self%NUMBER_OF_LATITUDES = 0

        ! Reset flag
        self%initialized = .false.

    end subroutine destroy_trigonometric_functions



    subroutine finalize_trigonometric_functions(self)
        !----------------------------------------------------------------------
        ! Dummy arguments
        !----------------------------------------------------------------------
        type(TrigonometricFunctions), intent(inout)     :: self
        !----------------------------------------------------------------------

        call self%destroy()

    end subroutine finalize_trigonometric_functions


end module type_TrigonometricFunctions
