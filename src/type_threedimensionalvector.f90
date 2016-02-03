!*****************************************************************************************
!
!  Purpose:
!
!  Defines a derived data type for 3-dimensional cartesian vector calculations
!
!*****************************************************************************************
!
module type_ThreeDimensionalVector

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: ThreeDimensionalVector
    public :: ThreeDimensionalVectorPointer
    public :: assignment(=)
    public :: operator(*)

    ! Declare derived data type
    type, public :: ThreeDimensionalVector

        ! All components are public unless stated otherwise
        !---------------------------------------------------------------------------------
        ! Real constants
        !---------------------------------------------------------------------------------
        real (wp)          :: x = 0.0_wp
        real (wp)          :: y = 0.0_wp
        real (wp)          :: z = 0.0_wp
        !---------------------------------------------------------------------------------

    contains

        ! All methods are private unless stated otherwise
        private

        !---------------------------------------------------------------------------------
        ! Private methods
        !---------------------------------------------------------------------------------
        procedure          :: add_vectors
        procedure          :: Subtract_vectors
        procedure          :: get_vector_divide_real
        procedure          :: get_vector_divide_integer
        procedure          :: get_dot_product
        procedure          :: convert_array_to_vector
        procedure, nopass  :: convert_vector_to_array
        procedure          :: copy_vector_to_vector
        procedure          :: get_vector_times_real
        procedure, nopass  :: get_real_times_vector
        procedure          :: get_vector_times_integer
        procedure, nopass  :: get_integer_times_vector
        procedure          :: get_cross_product
        !---------------------------------------------------------------------------------
        ! Public methods
        !---------------------------------------------------------------------------------
        procedure, public   :: get_norm
        generic,   public   :: operator (.dot.) => get_dot_product
        generic,   public   :: operator (+)     => add_vectors
        generic,   public   :: operator (-)     => Subtract_vectors
        generic,   public   :: operator (/)     => get_vector_divide_real, get_vector_divide_integer
        !---------------------------------------------------------------------------------
        ! Finalizer
        !---------------------------------------------------------------------------------
        final              :: Finalize_vector
        !---------------------------------------------------------------------------------

    end type ThreeDimensionalVector

    ! declare interface operators
    interface assignment (=)

        module procedure convert_array_to_vector
        module procedure convert_vector_to_array
        module procedure copy_vector_to_vector

    end interface

    interface operator (*)

        module procedure get_vector_times_real
        module procedure get_real_times_vector
        module procedure get_vector_times_integer
        module procedure get_integer_times_vector
        module procedure get_cross_product

    end interface

    ! To create array of pointers of TYPE (vector_t).
    type, public :: ThreeDimensionalVectorPointer

        ! All components are public unless stated otherwise
        type (ThreeDimensionalVector), pointer :: p => null()

    contains

        ! All methods are private unless stated otherwise
        private

        !---------------------------------------------------------------------------------
        ! Private methods
        !---------------------------------------------------------------------------------
        final             :: finalize_threedimensionalvectorpointer
        !---------------------------------------------------------------------------------

    end type ThreeDimensionalVectorPointer

contains
    !
    !*****************************************************************************************
    !
    subroutine convert_array_to_vector( this, array )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        class (ThreeDimensionalVector),   intent (out) :: this
        real (wp),          intent (in)  :: array(:)
        !--------------------------------------------------------------------------------

        this%x = array(1)
        this%y = array(2)
        this%z = array(3)

    end subroutine convert_array_to_vector
    !
    !*****************************************************************************************
    !
    subroutine convert_vector_to_array( array, this )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        real (wp),        intent (out) :: array(:)
        class (ThreeDimensionalVector), intent (in)  :: this
        !--------------------------------------------------------------------------------

        array(1) = this%x
        array(2) = this%y
        array(3) = this%z

    end subroutine convert_vector_to_array
    !
    !*****************************************************************************************
    !
    subroutine copy_vector_to_vector( this, vector_to_be_copied )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        class (ThreeDimensionalVector), intent (out) :: this
        class (ThreeDimensionalVector), intent (in)  :: vector_to_be_copied
        !--------------------------------------------------------------------------------

        this%x = vector_to_be_copied%x
        this%y = vector_to_be_copied%y
        this%z = vector_to_be_copied%z

    end subroutine copy_vector_to_vector
    !
    !*****************************************************************************************
    !
    function add_vectors( vec_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        class (ThreeDimensionalVector), intent (in) :: vec_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x + vec_2%x
        return_value%y = vec_1%y + vec_2%y
        return_value%z = vec_1%z + vec_2%z

    end function add_vectors
    !
    !*****************************************************************************************
    !
    function Subtract_vectors( vec_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        class (ThreeDimensionalVector), intent (in) :: vec_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x - vec_2%x
        return_value%y = vec_1%y - vec_2%y
        return_value%z = vec_1%z - vec_2%z

    end function Subtract_vectors
    !
    !*****************************************************************************************
    !
    function get_vector_times_real( vec_1, real_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        class (ThreeDimensionalVector), intent (in) :: vec_1
        real (wp),        intent (in) :: real_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x * real_2
        return_value%y = vec_1%y * real_2
        return_value%z = vec_1%z * real_2

    end function get_vector_times_real
    !
    !*****************************************************************************************
    !
    function get_real_times_vector(real_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        real (wp),        intent (in) :: real_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value%x = real_1 * vec_2%x
        return_value%y = real_1 * vec_2%y
        return_value%z = real_1 * vec_2%z

    end function get_real_times_vector
    !
    !*****************************************************************************************
    !
    function get_vector_times_integer( vec_1, int_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)                :: return_value
        class (ThreeDimensionalVector), intent (in)  :: vec_1
        integer (ip),     intent (in)  :: int_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x * real( int_2, wp)
        return_value%y = vec_1%y * real( int_2, wp)
        return_value%z = vec_1%z * real( int_2, wp)

    end function get_vector_times_integer
    !
    !*****************************************************************************************
    !
    function get_integer_times_vector( int_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        integer (ip),     intent (in) :: int_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value%x = real( int_1, wp) * vec_2%x
        return_value%y = real( int_1, wp) * vec_2%y
        return_value%z = real( int_1, wp) * vec_2%z

    end function get_integer_times_vector
    !
    !*****************************************************************************************
    !
    function get_vector_divide_real( vec_1, real_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)                :: return_value
        class (ThreeDimensionalVector), intent (in)  :: vec_1
        real (wp),        intent (in)  :: real_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x / real_2
        return_value%y = vec_1%y / real_2
        return_value%z = vec_1%z / real_2

    end function get_vector_divide_real
    !
    !*****************************************************************************************
    !
    function get_vector_divide_integer( vec_1, int_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)                :: return_value
        class (ThreeDimensionalVector), intent (in)  :: vec_1
        integer (ip),     intent (in)  :: int_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%x / int_2
        return_value%y = vec_1%y / int_2
        return_value%z = vec_1%z / int_2

    end function get_vector_divide_integer
    !
    !*****************************************************************************************
    !
    function get_dot_product( vec_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        real (wp)                     :: return_value
        class (ThreeDimensionalVector), intent (in) :: vec_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value = &
            vec_1%x*vec_2%x &
            + vec_1%y*vec_2%y &
            + vec_1%z*vec_2%z 

    end function get_dot_product
    !
    !*****************************************************************************************
    !
    function get_cross_product( vec_1, vec_2 ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector)               :: return_value
        class (ThreeDimensionalVector), intent (in) :: vec_1
        class (ThreeDimensionalVector), intent (in) :: vec_2
        !--------------------------------------------------------------------------------

        return_value%x = vec_1%y*vec_2%z - vec_1%z*vec_2%y
        return_value%y = vec_1%z*vec_2%x - vec_1%x*vec_2%z
        return_value%z = vec_1%x*vec_2%y - vec_1%y*vec_2%x

    end function get_cross_product
    !
    !*****************************************************************************************
    !
    function get_norm( this ) result ( return_value )
        !
        !< Purpose:
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        real (wp)                         :: return_value
        class (ThreeDimensionalVector), intent (in out) :: this
        !--------------------------------------------------------------------------------
        ! Dictionary: local variables
        !--------------------------------------------------------------------------------
        real (wp)                         :: array(3)
        !--------------------------------------------------------------------------------

        call convert_vector_to_array( array, this )

        return_value = norm2( array )

    end function get_norm
    !
    !*****************************************************************************************
    !
    elemental subroutine Finalize_vector( this )
        !
        !< Purpose:
        !< Finalize object
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVector), intent (in out) :: this
        !--------------------------------------------------------------------------------

        ! Reset constants

        this%x = 0.0_wp
        this%y = 0.0_wp
        this%z = 0.0_wp

    end subroutine Finalize_vector
    !
    !*****************************************************************************************
    !
    elemental subroutine finalize_threedimensionalvectorpointer( this )
        !
        !< Purpose:
        !< Finalize object
        !
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (ThreeDimensionalVectorPointer), intent (in out) :: this
        !--------------------------------------------------------------------------------

        ! Check if pointer is associated
        if ( associated( this%p ) ) then

            ! Nullify pointer
            nullify( this%p )

        end if


    end subroutine finalize_threedimensionalvectorpointer
    !
    !*****************************************************************************************
    !
end module type_ThreeDimensionalVector