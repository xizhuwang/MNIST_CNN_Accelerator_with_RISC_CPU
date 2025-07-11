module AI_Controller #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    output                      memory_data_mode,
    output                      MAC_rst_n,
    output                      MAC_en,
    output  [           1 : 0]  MAC_norm_mode,
    output                      Comparator_rst_n,
    output                      Comparator_en,
    output                      Comparator_load,
    output  [ADDR_BIT - 1 : 0]  weight_mem_addr,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      picture_mem_we,
    output  [           1 : 0]  result_sel,
    output                      busy,
    output                      done
);
        // state
    localparam  [4 - 1 : 0] IDLE            = 0;
    localparam  [4 - 1 : 0] CONV2D_l0       = 1;
    localparam  [4 - 1 : 0] RELU_l0         = 2;
    localparam  [4 - 1 : 0] MAXPOOL2D_l0    = 3;
    localparam  [4 - 1 : 0] CONV2D_l1       = 4;
    localparam  [4 - 1 : 0] RELU_l1         = 5;
    localparam  [4 - 1 : 0] MAXPOOL2D_l1    = 6;
    localparam  [4 - 1 : 0] FC_l2           = 7;
    localparam  [4 - 1 : 0] PREDICT_l3      = 8;

                
    reg                         Maxpool2d_start;          
    reg                         Maxpool2d_mode;

    wire                        Maxpool2d_rst_n;
    wire                        Maxpool2d_en;
    wire    [ADDR_BIT - 1 : 0]  Maxpool2d_picture_mem_addr;
    wire                        Maxpool2d_picture_mem_we;
    wire                        Maxpool2d_done;   
    reg                         Relu_start;          
    reg                         Relu_mode;

    wire    [ADDR_BIT - 1 : 0]  Relu_picture_mem_addr;
    wire                        Relu_picture_mem_we;
    wire                        Relu_done;   

    reg                         RL_rst_n;
    reg                         RL_rst_n_r1;
    reg                         MP_rst_n;
    reg                         MP_rst_n_r1;
    
    reg                         CS_rst_n;
    reg                         CS_rst_n_r1;

    reg                         Conv2d_start;          
    reg                         Conv2d_mode; 

    wire    [           1 : 0]  Conv2d_MAC_norm_mode;
    wire                        Conv2d_MAC_rst_n;
    wire                        Conv2d_MAC_en;

    wire    [ADDR_BIT - 1 : 0]  Conv2d_picture_mem_addr;
    wire                        Conv2d_picture_mem_we;
    wire    [ADDR_BIT - 1 : 0]  Conv2d_weight_mem_addr;
    wire                        Conv2d_done;   
    
    reg                         FC_start; 

    wire    [           1 : 0]  FC_MAC_norm_mode;
    wire                        FC_MAC_rst_n;
    wire                        FC_MAC_en;

    wire    [ADDR_BIT - 1 : 0]  FC_picture_mem_addr;
    wire                        FC_picture_mem_we;
    wire    [ADDR_BIT - 1 : 0]  FC_weight_mem_addr;
    wire                        FC_done;  

    reg                     FC_rst_n;
    reg                     FC_rst_n_r1;
    
    reg                         PL_rst_n;
    reg                         PL_rst_n_r1;
    reg                         PL_start           ;
    wire                        PL_en              ;
    wire                        PL_Comparator_rst_n;
    wire    [ADDR_BIT - 1 : 0]  PL_picture_mem_addr;
    wire                        PL_done            ;

        reg         [4 - 1 : 0] cur_state;
    reg         [4 - 1 : 0] next_state;

    reg                      memory_data_mode_w;
    reg                      MAC_rst_n_w;
    reg                      MAC_en_w;
    reg         [    1 : 0]  MAC_norm_mode_w;
    reg                      Comparator_rst_n_w;
    reg                      Comparator_en_w;
    // reg                      Maxpool2d_rst_n_w;
    reg  [ADDR_BIT - 1 : 0]  weight_mem_addr_w;
    reg  [ADDR_BIT - 1 : 0]  picture_mem_addr_w;
    reg                      picture_mem_we_w;
    reg  [           1 : 0]  result_sel_w;
    reg                      busy_w;
    reg                      done_w;

    always @(posedge clk) begin
        CS_rst_n_r1 <= CS_rst_n;
        RL_rst_n_r1 <= RL_rst_n;
        MP_rst_n_r1 <= MP_rst_n;
        FC_rst_n_r1 <= FC_rst_n;
        PL_rst_n_r1 <= PL_rst_n;
    end

    Conv2d_schedular #(
        .ADDR_BIT           (ADDR_BIT)
    ) U_Conv2d_schedular (
        .clk                (clk),
        .rst_n              (CS_rst_n_r1&rst_n),
        .start              (Conv2d_start),
        .mode               (Conv2d_mode),
        .MAC_norm_mode      (Conv2d_MAC_norm_mode),
        .MAC_rst_n          (Conv2d_MAC_rst_n),
        .MAC_en             (Conv2d_MAC_en),
        .picture_mem_addr   (Conv2d_picture_mem_addr),
        .picture_mem_we     (Conv2d_picture_mem_we),
        .weight_mem_addr    (Conv2d_weight_mem_addr),
        .done               (Conv2d_done)
    );

    Relu_scheduler #(
        .ADDR_BIT           (ADDR_BIT)
    ) U_Relu_scheduler (
        .clk                (clk),
        .rst_n              (RL_rst_n_r1&rst_n),
        .start              (Relu_start),
        .mode               (Relu_mode),
        .picture_mem_addr   (Relu_picture_mem_addr),
        .picture_mem_we     (Relu_picture_mem_we),
        .done               (Relu_done)
    );

    Maxpool2d_scheduler #(
        .ADDR_BIT           (ADDR_BIT)
    ) U_Maxpool2d_scheduler (
        .clk                (clk),
        .rst_n              (MP_rst_n_r1&rst_n),
        .start              (Maxpool2d_start),
        .mode               (Maxpool2d_mode),
        .Maxpool2d_rst_n    (Maxpool2d_rst_n),
        .Maxpool2d_en       (Maxpool2d_en),
        .picture_mem_addr   (Maxpool2d_picture_mem_addr),
        .picture_mem_we     (Maxpool2d_picture_mem_we),
        .done               (Maxpool2d_done)
    );

    FC_scheduler #(
        .ADDR_BIT           (ADDR_BIT)
    ) U_FC_scheduler (
        .clk                (clk),
        .rst_n              (FC_rst_n_r1&rst_n),
        .start              (FC_start),
        .MAC_norm_mode      (FC_MAC_norm_mode),
        .MAC_rst_n          (FC_MAC_rst_n),
        .MAC_en             (FC_MAC_en),
        .picture_mem_addr   (FC_picture_mem_addr),
        .picture_mem_we     (FC_picture_mem_we),
        .weight_mem_addr    (FC_weight_mem_addr),
        .done               (FC_done)
    );

    Predict_label_scheduler #(
        .ADDR_BIT           (ADDR_BIT)
    ) U_Predict_label_scheduler (
       .clk                 (clk                ),
       .rst_n               (PL_rst_n_r1&rst_n  ),
       .start               (PL_start           ),
       .Comparator_rst_n    (PL_Comparator_rst_n),
       .Comparator_en       (PL_en              ),
       .Comparator_load     (Comparator_load    ),
       .picture_mem_addr    (PL_picture_mem_addr),
       .done                (PL_done            )
    );

    assign  memory_data_mode    = memory_data_mode_w;
    assign  MAC_rst_n           = MAC_rst_n_w;       
    assign  MAC_en              = MAC_en_w;           
    assign  MAC_norm_mode       = MAC_norm_mode_w;   
    // assign  Maxpool2d_rst       = Maxpool2d_rst_w;
    assign  Comparator_rst_n    = Comparator_rst_n_w;   
    assign  Comparator_en       = Comparator_en_w;
    assign  weight_mem_addr     = weight_mem_addr_w;   
    assign  picture_mem_addr    = picture_mem_addr_w;
    assign  picture_mem_we      = picture_mem_we_w;  
    assign  result_sel          = result_sel_w; 
    assign  busy                = busy_w;
    assign  done                = done_w;            

    // state transition
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cur_state <= IDLE;
        end else begin
            cur_state <= next_state;
        end
    end

    always @(*) begin
        case (cur_state)
            IDLE: begin
                next_state = start? CONV2D_l0:IDLE;
            end 
            CONV2D_l0: begin
                next_state = Conv2d_done? RELU_l0:CONV2D_l0;
            end 
            RELU_l0: begin
                next_state = Relu_done? MAXPOOL2D_l0:RELU_l0;
            end 
            MAXPOOL2D_l0: begin
                next_state = Maxpool2d_done? CONV2D_l1:MAXPOOL2D_l0;
            end 
            CONV2D_l1: begin
                next_state = Conv2d_done? RELU_l1:CONV2D_l1;
            end 
            RELU_l1: begin
                next_state = Relu_done? MAXPOOL2D_l1:RELU_l1;
            end 
            MAXPOOL2D_l1: begin
                next_state = Maxpool2d_done? FC_l2:MAXPOOL2D_l1;
            end 
            FC_l2: begin
                next_state = FC_done? PREDICT_l3:FC_l2;
            end 
            PREDICT_l3: begin
                next_state = PL_done? IDLE:PREDICT_l3;
            end 
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        case (cur_state)
            IDLE: begin
                memory_data_mode_w  = 1;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;

                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = 0;
                picture_mem_we_w    = 0;
                result_sel_w        = 0;
                busy_w              = start? 1:0;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;
                
                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            CONV2D_l0: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = Conv2d_MAC_rst_n;
                MAC_en_w            = Conv2d_MAC_en;
                MAC_norm_mode_w     = Conv2d_MAC_norm_mode;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;

                weight_mem_addr_w   = Conv2d_weight_mem_addr;
                picture_mem_addr_w  = Conv2d_picture_mem_addr;
                picture_mem_we_w    = Conv2d_picture_mem_we;
                result_sel_w        = 0;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 1;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = Conv2d_done? 0:1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            RELU_l0: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = Relu_picture_mem_addr;
                picture_mem_we_w    = Relu_picture_mem_we;
                result_sel_w        = 1;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 1;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = 1;
                RL_rst_n            = Relu_done? 0:1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            MAXPOOL2D_l0: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = Maxpool2d_rst_n;
                Comparator_en_w     = Maxpool2d_en;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = Maxpool2d_picture_mem_addr;
                picture_mem_we_w    = Maxpool2d_picture_mem_we;
                result_sel_w        = 2;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 1;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = Maxpool2d_done? 0:1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            CONV2D_l1: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = Conv2d_MAC_rst_n;
                MAC_en_w            = Conv2d_MAC_en;
                MAC_norm_mode_w     = Conv2d_MAC_norm_mode;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;
                
                weight_mem_addr_w   = Conv2d_weight_mem_addr;
                picture_mem_addr_w  = Conv2d_picture_mem_addr;
                picture_mem_we_w    = Conv2d_picture_mem_we;
                result_sel_w        = 0;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 1;
                Conv2d_mode         = 1;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = Conv2d_done? 0:1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            RELU_l1: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = Relu_picture_mem_addr;
                picture_mem_we_w    = Relu_picture_mem_we;
                result_sel_w        = 1;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 1;
                Relu_mode           = 1;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = 1;
                RL_rst_n            = Relu_done? 0:1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            MAXPOOL2D_l1: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = Maxpool2d_rst_n;
                Comparator_en_w     = Maxpool2d_en;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = Maxpool2d_picture_mem_addr;
                picture_mem_we_w    = Maxpool2d_picture_mem_we;
                result_sel_w        = 2;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 1;
                Maxpool2d_mode      = 1;
                FC_start            = 0;
                PL_start            = 0;

                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = Maxpool2d_done? 0:1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end 
            FC_l2: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = FC_MAC_rst_n;
                MAC_en_w            = FC_MAC_en;
                MAC_norm_mode_w     = FC_MAC_norm_mode;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;
                
                weight_mem_addr_w   = FC_weight_mem_addr;
                picture_mem_addr_w  = FC_picture_mem_addr;
                picture_mem_we_w    = FC_picture_mem_we;
                result_sel_w        = 0;
                busy_w              = 1;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 1;
                PL_start            = 0;

                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = FC_done? 0:1;
                PL_rst_n            = 1;
            end 
            PREDICT_l3: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = PL_Comparator_rst_n;
                Comparator_en_w     = PL_en;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = PL_picture_mem_addr;
                picture_mem_we_w    = 0;
                result_sel_w        = 0;
                busy_w              = PL_done? 0:1;
                done_w              = PL_done? 1:0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 1;

                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = PL_done? 0:1;
            end 
            default: begin
                memory_data_mode_w  = 0;
                MAC_rst_n_w         = 1;
                MAC_en_w            = 0;
                MAC_norm_mode_w     = 0;
                Comparator_rst_n_w  = 1;
                Comparator_en_w     = 0;
                
                weight_mem_addr_w   = 0;
                picture_mem_addr_w  = 0;
                picture_mem_we_w    = 0;
                result_sel_w        = 0;
                busy_w              = 0;
                done_w              = 0;

                Conv2d_start        = 0;
                Conv2d_mode         = 0;
                Relu_start          = 0;
                Relu_mode           = 0;
                Maxpool2d_start     = 0;
                Maxpool2d_mode      = 0;
                FC_start            = 0;
                PL_start            = 0;
                
                CS_rst_n            = 1;
                RL_rst_n            = 1;
                MP_rst_n            = 1;
                FC_rst_n            = 1;
                PL_rst_n            = 1;
            end
        endcase
    end

    
endmodule