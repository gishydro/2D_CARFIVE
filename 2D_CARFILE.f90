!  $2D_CARFILE.f90 
!
!  FUNCTIONS:
!  $2D_CARFILE - Entry point of console application.
!

!*************************************************************************************************
!
!  PROGRAM: $2D_CARFILE
!
!  PURPOSE:  Entry point for the console application.
!
!*************************************************************************************************
!=================================================================================================
!> CARTESIAN ADAPTIVE FIVE EQUATION MODEL
!> AUTHOR: VAN-DAT THANG
!> E-MAIL: datthangva@gmail.com
!> E-MAIL: vandatthang@gmail.com
!> SOURCE CODE LINK: https://github.com/dattv/2D_CARFIVE
!=================================================================================================     

    program $2D_CARFILE

    use MODULE_PRECISION
    use MODULE_CONSTANTS
    use MODULE_CFDMAINDATA
    use MODULE_QUADTREE
    USE MODULE_OUTPUT
    use MODULE_MAKEGRID
    USE MODULE_INITIALCONDITION
    use MODULE_AMR
    use MODULE_SOLVER
    
    implicit none

    ! Variables
    integer(ip)                                 :: NQ
    integer(ip)                                 :: nelm
    integer(ip)                                 :: I_solver_type
    type(quadtree), dimension(:), allocatable   :: tree
    ! Body of $2D_CARFILE
    
    ! ===> SETUP INITIAL VALUE <===================================================================
    M_inf = zero;   gamma = 1.4_rp; NQ = 6; nelm = 900;
    time_step_max = 50000000
    t_final = 0.2_rp;   CFL = 0.7_rp
    
    C_limiter_type = "superbee" ;   C_inviscid_flux = "rusanov"
    I_limiter_type = 1          ;   I_inviscid_flux = 1
    
    ! ===> MAKE QUADTREE GRID NELM CELL <==========================================================
    call make_grid_2d(nelm, (/zero, one/), (/zero, one/), NQ, tree)

    ! ===> TWO MATERIAL (IN HERE I ASSUME THEY ARE GAS AND LIQUID) <===============================
    allocate(matInfo(2))
    
    ! ===> SETUP TWO PROPERTIES <==================================================================
    rho_inf = 1.e3_rp; u_inf = 1500._rp; p_inf = 1.e9_rp; L_inf = 1._rp
                    matInfo(1)%gamma = 4.4_rp    ;                 matInfo(2)%gamma = 4.4_rp    
                        matInfo(1)%B = 1._rp     ;                     matInfo(2)%B = 1._rp     
                      matInfo(1)%RHO = 1000._rp  ;                   matInfo(2)%RHO = 1000._rp  
           matInfo(1)%r_gas_constant = 8.3_rp    ;        matInfo(2)%r_gas_constant = 8.3_rp    
                       matInfo(1)%mu = 1._rp     ;                    matInfo(2)%mu = 1._rp     
                   matInfo(1)%lambda = 1._rp     ;                matInfo(2)%lambda = 1._rp     
    matInfo(1)%c_sutherland_constant = 1._rp     ; matInfo(2)%c_sutherland_constant = 1._rp     
              matInfo(1)%temperature = 293.15_rp ;           matInfo(2)%temperature = 293.15_rp 
                       matInfo(1)%pi = 6.e8_rp   ;                    matInfo(2)%pi = 6.e8_rp   
                       matInfo(1)%cp = 4.1813_rp ;                    matInfo(2)%cp = 4.1813_rp 
            
    matInfo(1)%rho = matInfo(1)%rho/ rho_inf; matInfo(2)%rho = matInfo(2)%rho/ rho_inf
    matInfo(1)%pi  = matInfo(1)%pi/ p_inf;    matInfo(2)%pi  = matInfo(2)%pi/ p_inf  
    
    frequency_dump = 100    
    
    ! ===> SETUP INITIAL CONDITION FOR MULTIPHASE FLOWS <==========================================
    call initial_condition(nelm, tree)
    
    ! ===> ADAPTIAVE MESH FOR INITIAL CONDITION <==================================================
    call AMR_whole_domain(1, nelm, tree)
    
    ! ===> PRINT OUT INITIAL CONDITION <===========================================================
    call output_2D("INITIAL.TEC", nelm, tree)
    
    I_solver_type = 2   ! second order explicit
    call solving(1, nelm, tree, I_solver_type)
    


    end program $2D_CARFILE

