/**************************************
@ filename    : openmips.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:46:45
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module openmips (
    input  logic                      i_clk            ,
    input  logic                      i_rst_n          ,
      
    input  logic [`N_INST_DATA-1:0]   i_inst_data      ,
      
    output logic                      o_inst_ren       ,
    output logic [`N_INST_ADDR-1:0]   o_inst_addr      ,
      
    input  logic [`N_MEM_DATA-1:0]    i_ram_data       ,
      
    output logic [`N_MEM_ADDR-1:0]    o_ram_addr       ,
    output logic [`N_MEM_DATA-1:0]    o_ram_data       ,
    output logic                      o_ram_we         ,
    output logic                      o_ram_ce         ,
    output logic [3:0]                o_ram_sel        ,

    input  logic [`CP0_REG_N_INT-1:0] i_interrupt      ,
    output logic                      o_timer_interrupt
);

/********************** define if_id2id begin ***********************/
logic [`N_INST_ADDR-1:0]    if_id2id_pc             ;
logic [`N_INST_DATA-1:0]    if_id2id_inst           ;
/********************** define if_id2id  end  ***********************/

/********************** define id2regfile begin ***********************/
logic [`N_REG_ADDR-1:0]     id2regfile_reg_0_addr   ;
logic                       id2regfile_reg_0_ren    ;
logic [`N_REG_ADDR-1:0]     id2regfile_reg_1_addr   ;
logic                       id2regfile_reg_1_ren    ;
/********************** define id2regfile  end  ***********************/

/********************** define id2ex begin ***********************/
logic [`N_ALU_OP-1:0]       id2ex_alu_op            ;
logic [`N_ALU_SEL-1:0]      id2ex_alu_sel           ;
logic [`N_REG-1:0]          id2ex_op_reg_0          ;
logic [`N_REG-1:0]          id2ex_op_reg_1          ;
logic                       id2ex_reg_wen           ;
logic [`N_REG_ADDR-1:0]     id2ex_reg_waddr         ;
logic                       id2ex_delayslot_vld     ;
logic [`N_INST_ADDR-1:0]    id2ex_link_addr         ;
logic                       id2ex_next_delayslot_vld;
logic [`N_INST_ADDR-1:0]    id2ex_inst              ;

logic [31:0]                id2ex_except_type       ;
logic [`N_INST_ADDR-1:0]    id2ex_curr_inst_addr    ;
/********************** define id2ex  end  ***********************/

/********************** define regfile2id begin ***********************/
logic [`N_REG-1:0]          regfile2id_rdata_0      ;
logic [`N_REG-1:0]          regfile2id_rdata_1      ;
/********************** define regfile2id  end  ***********************/

/********************** define id_ex2ex begin ***********************/
logic [`N_ALU_OP-1:0 ]      id_ex2ex_ex_alu_op      ;
logic [`N_ALU_SEL-1:0]      id_ex2ex_ex_alu_sel     ;
logic [`N_REG-1:0]          id_ex2ex_ex_reg_0       ;
logic [`N_REG-1:0]          id_ex2ex_ex_reg_1       ;
logic                       id_ex2ex_ex_reg_wen     ;
logic [`N_REG_ADDR-1:0]     id_ex2ex_ex_reg_waddr   ;
logic                       id_ex2ex_delayslot_vld  ;
logic [`N_INST_ADDR-1:0]    id_ex2ex_link_addr      ;
logic [`N_INST_ADDR-1:0]    id_ex2ex_inst           ;
logic [31:0]                id_ex2ex_except_type    ;
logic [`N_INST_ADDR-1:0]    id_ex2ex_curr_inst_addr ;
/********************** define id_ex2ex  end  ***********************/

/********************** define ex2ex_mem begin ***********************/
logic                       ex2ex_mem_alu_reg_wen   ;
logic [`N_REG_ADDR-1:0]     ex2ex_mem_alu_reg_waddr ;
logic [`N_REG-1:0]          ex2ex_mem_alu_reg_wdata ;
logic                       ex2ex_mem_hilo_wen      ;
logic [`N_REG-1:0]          ex2ex_mem_hi            ;
logic [`N_REG-1:0]          ex2ex_mem_lo            ; 
logic [`N_REG*2-1:0]        ex2ex_mem_hilo_temp     ;
logic [1:0]                 ex2ex_mem_cnt           ;
logic [`N_ALU_OP-1:0]       ex2ex_mem_alu_op        ;
logic [`N_MEM_ADDR-1:0]     ex2ex_mem_addr          ;
logic [`N_MEM_DATA-1:0]     ex2ex_mem_data          ;
logic                       ex2ex_mem_cp0_reg_wen   ;
logic [`CP0_REG_N_ADDR-1:0] ex2ex_mem_cp0_reg_waddr ;
logic [`N_REG-1:0]          ex2ex_mem_cp0_reg_wdata ; 
logic [31:0]                ex2ex_mem_except_type   ;
logic [`N_INST_ADDR-1:0]    ex2ex_mem_curr_inst_addr;
logic                       ex2ex_mem_delayslot_vld ;
/********************** define ex2ex_mem  end  ***********************/

/********************** define ex_mem2ex begin ***********************/
logic [`N_REG*2-1:0]        ex_mem2ex_hilo_temp     ;
logic [1:0]                 ex_mem2ex_cnt           ;
/********************** define ex_mem2ex  end  ***********************/

/********************** define ex_mem2mem begin ***********************/
logic                       ex_mem2mem_wen           ;
logic [`N_REG-1:0]          ex_mem2mem_wdata         ;
logic [`N_REG_ADDR-1:0]     ex_mem2mem_waddr         ;
logic                       ex_mem2mem_hilo_wen      ;
logic [`N_REG-1:0]          ex_mem2mem_hi            ;
logic [`N_REG-1:0]          ex_mem2mem_lo            ;
logic [`N_ALU_OP-1:0]       ex_mem2mem_aluop         ;
logic [`N_MEM_ADDR-1:0]     ex_mem2mem_addr          ;
logic [`N_MEM_DATA-1:0]     ex_mem2mem_data          ;
logic                       ex_mem2mem_cp0_reg_wen   ;
logic [`CP0_REG_N_ADDR-1:0] ex_mem2mem_cp0_reg_waddr ;
logic [`N_REG-1:0]          ex_mem2mem_cp0_reg_wdata ;
logic [31:0]                ex_mem2mem_except_type   ;
logic [`N_INST_ADDR-1:0]    ex_mem2mem_curr_inst_addr;
logic                       ex_mem2mem_delayslot_vld ;
/********************** define ex_mem2mem  end  ***********************/

/********************** define mem2mem_wb begin ***********************/
logic                       mem2mem_wb_wen          ; 
logic [`N_REG_ADDR-1:0]     mem2mem_wb_waddr        ; 
logic [`N_REG-1:0]          mem2mem_wb_wdata        ; 
logic                       mem2mem_wb_hilo_wen     ;
logic [`N_REG-1:0]          mem2mem_wb_hi           ;
logic [`N_REG-1:0]          mem2mem_wb_lo           ;  
logic                       mem2mem_llbit_wen       ;
logic                       mem2mem_llbit_data      ;
logic                       mem2mem_wb_cp0_reg_wen  ;
logic [`CP0_REG_N_ADDR-1:0] mem2mem_wb_cp0_reg_waddr;
logic [`N_REG-1:0]          mem2mem_wb_cp0_reg_wdata;
/********************** define mem2mem_wb  end  ***********************/

/********************** define mem_wb2regfile begin ***********************/
logic [`N_REG_ADDR-1:0]     mem_wb2regfile_waddr    ;  
logic [`N_REG-1:0]          mem_wb2regfile_wdata    ;  
logic                       mem_wb2regfile_wen      ; 
/********************** define mem_wb2regfile  end  ***********************/ 

/********************** define mem_wb2hilo begin ***********************/
logic                       mem_wb2hilo_wen         ;
logic [`N_REG-1:0]          mem_wb2hilo_hi          ;
logic [`N_REG-1:0]          mem_wb2hilo_lo          ;
/********************** define mem_wb2hilo  end  ***********************/ 

/********************** define hilo2ex begin ***********************/
logic [`N_REG-1:0]          hilo2ex_hi              ;
logic [`N_REG-1:0]          hilo2ex_lo              ;
/********************** define hilo2ex  end  ***********************/

/********************** define pctrl2others begin ******************/
logic [5:0]                 pctrl2others_stall      ;
logic                       pctrl2others_flush      ;         
/********************** define pctrl2others  end  ******************/

/********************** define id2pctrl begin **********************/
logic                       id2pctrl_streq          ;
/********************** define id2pctrl  end  **********************/

/********************** define ex2pctrl begin **********************/
logic                       ex2pctrl_streq          ;
/********************** define ex2pctrl  end  **********************/

/********************** define ex2div begin **********************/
logic                       ex2div_divsigned        ;
logic [`N_REG-1:0]          ex2div_dividend         ;
logic [`N_REG-1:0]          ex2div_divisor          ;
logic                       ex2div_divstart         ;
/********************** define ex2div  end  **********************/

/********************** define div2ex begin **********************/
logic [`N_REG-1:0]          div2ex_quotient         ;
logic [`N_REG-1:0]          div2ex_remainder        ;
logic                       div2ex_div_done         ;
logic                       div2ex_div_ready        ;   
/********************** define div2ex  end  **********************/

/********************** define id2pc begin **********************/
logic                       id2pc_branch_vld        ;
logic [`N_INST_ADDR-1:0]    id2pc_branch_addr       ;
/********************** define id2pc  end  **********************/

/********************** define id_ex2id begin **********************/
logic                       id_ex2id_delayslot_vld  ;
/********************** define id_ex2id  end  **********************/

/********************** define llbit2mem begin **********************/
logic                       llbit2mem_llbit         ;
/********************** define llbit2mem  end  **********************/

/********************** define mem_wb2llbit begin **********************/
logic                       mem_wb2llbit_wen        ;
logic                       mem_wb2llbit_data       ;
/********************** define mem_wb2llbit  end  **********************/

/********************** define ex2cp0 begin **********************/
logic [`CP0_REG_N_ADDR-1:0] ex2cp0_reg_raddr        ;
/********************** define ex2cp0  end  **********************/

/********************** define mem_wb2cp0 begin **********************/
logic                       mem_wb2cp0_reg_wen      ;
logic [`CP0_REG_N_ADDR-1:0] mem_wb2cp0_reg_waddr    ;
logic [`N_REG-1:0]          mem_wb2cp0_reg_wdata    ;
/********************** define mem_wb2cp0  end  **********************/

/********************** define cp02ex begin **********************/
logic [`N_REG-1:0]          cp02ex_data             ;
/********************** define cp02ex  end  **********************/

/********************** define pctrl2pc begin **********************/
logic [`N_INST_ADDR-1:0]    pctrl2pc_new_pc         ;  
/********************** define pctrl2pc  end  **********************/

/********************** define cp02mem begin **********************/
logic [`N_REG-1:0]          cp02mem_status          ; 
logic [`N_REG-1:0]          cp02mem_cause           ; 
logic [`N_REG-1:0]          cp02mem_epc             ;
/********************** define cp02mem  end  **********************/

/********************** define mem2cp0 begin **********************/
logic [31:0]                mem2cp0_except_type     ;
logic [`N_REG-1:0]          mem2cp0_curr_inst_addr  ;
logic                       mem2cp0_delayslot_vld   ;
/********************** define mem2cp0  end  **********************/

/********************** define mem2pctrl begin **********************/
logic [`N_REG-1:0]          mem2pctrl_cp0_epc       ;
/********************** define mem2pctrl  end  **********************/

pc_reg pc_reg_inst (
    .i_clk        (i_clk             ),
    .i_rst_n      (i_rst_n           ),
    .i_stall      (pctrl2others_stall),
    .o_pc         (o_inst_addr       ),
    .o_ce         (o_inst_ren        ),

    .i_branch_addr(id2pc_branch_addr ),
    .i_branch_vld (id2pc_branch_vld  ),

    .i_flush      (pctrl2others_flush),
    .i_new_pc     (pctrl2pc_new_pc   )
);

if_id if_id_inst ( 
    .i_clk     (i_clk             ),
    .i_rst_n   (i_rst_n           ),
    .i_if_pc   (o_inst_addr       ),
    .i_if_inst (i_inst_data       ),
    .i_stall   (pctrl2others_stall),
    .o_id_pc   (if_id2id_pc       ),
    .o_id_inst (if_id2id_inst     ),
    
    .i_flush   (pctrl2others_flush)
);

id id_inst ( 
    .i_pc                (if_id2id_pc             ),
    .i_inst              (if_id2id_inst           ),

    // input regfile value
    .i_reg_0_data        (regfile2id_rdata_0      ),
    .i_reg_1_data        (regfile2id_rdata_1      ),

    // output regfile read ctrl signal
    .o_reg_0_addr        (id2regfile_reg_0_addr   ),
    .o_reg_0_ren         (id2regfile_reg_0_ren    ),
    .o_reg_1_addr        (id2regfile_reg_1_addr   ),
    .o_reg_1_ren         (id2regfile_reg_1_ren    ),

    // output signal to execute state 
    .o_alu_op            (id2ex_alu_op            ),  // operator sub type  --> or , and , xor ...
    .o_alu_sel           (id2ex_alu_sel           ),  // operator type      --> logic , arithmetic operation
    .o_op_reg_0          (id2ex_op_reg_0          ),  // operate data 0
    .o_op_reg_1          (id2ex_op_reg_1          ),  // operate data 1
    .o_reg_wen           (id2ex_reg_wen           ),  // dst reg w enable signal
    .o_reg_waddr         (id2ex_reg_waddr         ),  // dst reg addr

     // input signal from ex stage
    .i_ex_wen            (ex2ex_mem_alu_reg_wen   ),
    .i_ex_waddr          (ex2ex_mem_alu_reg_waddr ),
    .i_ex_wdata          (ex2ex_mem_alu_reg_wdata ),
    // input signal from mem stage
    .i_mem_wen           (mem2mem_wb_wen          ),
    .i_mem_waddr         (mem2mem_wb_waddr        ),
    .i_mem_wdata         (mem2mem_wb_wdata        ),

    .o_streq             (id2pctrl_streq          ),

    .o_branch_addr       (id2pc_branch_addr       ),
    .o_branch_vld        (id2pc_branch_vld        ),

    .o_delayslot_vld     (id2ex_delayslot_vld     ),
    .o_link_addr         (id2ex_link_addr         ),
    
    .o_next_delayslot_vld(id2ex_next_delayslot_vld),

    .i_delayslot_vld     (id_ex2id_delayslot_vld  ),

    .o_inst              (id2ex_inst              ),

    .i_ex_aluop          (ex2ex_mem_alu_op        ),

    .o_except_type       (id2ex_except_type       ),
    .o_curr_inst_addr    (id2ex_curr_inst_addr    ) 
);

regfile regfile_inst (
    .i_clk     (i_clk                ),
    .i_rst_n   (i_rst_n              ),
    .i_waddr   (mem_wb2regfile_waddr ),
    .i_wdata   (mem_wb2regfile_wdata ),
    .i_wen     (mem_wb2regfile_wen   ),

    .i_raddr_0 (id2regfile_reg_0_addr),
    .i_ren_0   (id2regfile_reg_0_ren ),
    .o_rdata_0 (regfile2id_rdata_0   ),
    .i_raddr_1 (id2regfile_reg_1_addr),
    .i_ren_1   (id2regfile_reg_1_ren ),
    .o_rdata_1 (regfile2id_rdata_1   )  
);

id_ex id_ex_inst (
    .i_clk               (i_clk                    ),
    .i_rst_n             (i_rst_n                  ),

    .i_id_alu_op         (id2ex_alu_op             ),
    .i_id_alu_sel        (id2ex_alu_sel            ),
    .i_id_reg_0          (id2ex_op_reg_0           ),
    .i_id_reg_1          (id2ex_op_reg_1           ),
    .i_id_reg_wen        (id2ex_reg_wen            ),
    .i_id_reg_waddr      (id2ex_reg_waddr          ),  
    .i_stall             (pctrl2others_stall       ), 

    .o_ex_alu_op         (id_ex2ex_ex_alu_op       ),
    .o_ex_alu_sel        (id_ex2ex_ex_alu_sel      ),
    .o_ex_reg_0          (id_ex2ex_ex_reg_0        ),
    .o_ex_reg_1          (id_ex2ex_ex_reg_1        ),
    .o_ex_reg_wen        (id_ex2ex_ex_reg_wen      ),
    .o_ex_reg_waddr      (id_ex2ex_ex_reg_waddr    ),

    .i_id_delayslot_vld  (id2ex_delayslot_vld      ),
    .i_id_link_addr      (id2ex_link_addr          ),
    .i_next_delayslot_vld(id2ex_next_delayslot_vld ),

    .o_ex_delayslot_vld  (id_ex2ex_delayslot_vld   ),
    .o_ex_link_addr      (id_ex2ex_link_addr       ),
    .o_delayslot_vld     (id_ex2id_delayslot_vld   ),

    .i_id_inst           (id2ex_inst               ),
    .o_ex_inst           (id_ex2ex_inst            ),

    .i_flush             (pctrl2others_flush       ),
    .i_id_except_type    (id2ex_except_type        ),
    .i_id_curr_inst_addr (id2ex_curr_inst_addr     ),
    .o_ex_except_type    (id_ex2ex_except_type     ),
    .o_ex_curr_inst_addr (id_ex2ex_curr_inst_addr  )
);

ex ex_inst ( 
    .i_alu_sel          (id_ex2ex_ex_alu_sel     ),
    .i_alu_op           (id_ex2ex_ex_alu_op      ),
    .i_alu_reg_0        (id_ex2ex_ex_reg_0       ),
    .i_alu_reg_1        (id_ex2ex_ex_reg_1       ),
    .i_alu_reg_wen      (id_ex2ex_ex_reg_wen     ),
    .i_alu_reg_waddr    (id_ex2ex_ex_reg_waddr   ),
        
    .o_alu_reg_wen      (ex2ex_mem_alu_reg_wen   ),
    .o_alu_reg_waddr    (ex2ex_mem_alu_reg_waddr ),
    .o_alu_reg_wdata    (ex2ex_mem_alu_reg_wdata ),
    
    .i_hi               (hilo2ex_hi              ),
    .i_lo               (hilo2ex_lo              ),
    
    .i_mem_hilo_wen     (mem2mem_wb_hilo_wen     ),
    .i_mem_hi           (mem2mem_wb_hi           ),
    .i_mem_lo           (mem2mem_wb_lo           ),
    
    .i_wb_hilo_wen      (mem_wb2hilo_wen         ),
    .i_wb_hi            (mem_wb2hilo_hi          ),
    .i_wb_lo            (mem_wb2hilo_lo          ),
    
    .o_hilo_wen         (ex2ex_mem_hilo_wen      ),
    .o_hi               (ex2ex_mem_hi            ),
    .o_lo               (ex2ex_mem_lo            ),
        
    .o_streq            (ex2pctrl_streq          ),
    
    .i_hilo_temp        (ex_mem2ex_hilo_temp     ),
    .i_cnt              (ex_mem2ex_cnt           ),
    
    .o_hilo_temp        (ex2ex_mem_hilo_temp     ),
    .o_cnt              (ex2ex_mem_cnt           ),
    
    .o_divsigned        (ex2div_divsigned        ),
    .o_dividend         (ex2div_dividend         ),
    .o_divisor          (ex2div_divisor          ),
    .o_divstart         (ex2div_divstart         ),
    
    .i_quotient         (div2ex_quotient         ),
    .i_remainder        (div2ex_remainder        ),
    .i_div_done         (div2ex_div_done         ),
    .i_div_ready        (div2ex_div_ready        ),
    
    .i_delayslot_vld    (id_ex2ex_delayslot_vld  ),
    .i_link_addr        (id_ex2ex_link_addr      ),
    
    .i_inst             (id_ex2ex_inst           ),
    .o_alu_op           (ex2ex_mem_alu_op        ),
    .o_mem_addr         (ex2ex_mem_addr          ),
    .o_mem_data         (ex2ex_mem_data          ),

    .i_mem_cp0_reg_wen  (ex_mem2mem_cp0_reg_wen  ),
    .i_mem_cp0_reg_waddr(ex_mem2mem_cp0_reg_waddr),
    .i_mem_cp0_reg_data (ex_mem2mem_cp0_reg_wdata),

    .i_wb_cp0_reg_wen   (mem_wb2cp0_reg_wen      ),
    .i_wb_cp0_reg_waddr (mem_wb2cp0_reg_waddr    ),
    .i_wb_cp0_reg_data  (mem_wb2cp0_reg_wdata    ),

    .i_cp0_reg_data     (cp02ex_data             ),
    .o_cp0_reg_raddr    (ex2cp0_reg_raddr        ),

    .o_cp0_reg_wen      (ex2ex_mem_cp0_reg_wen   ),
    .o_cp0_reg_waddr    (ex2ex_mem_cp0_reg_waddr ),
    .o_cp0_reg_wdata    (ex2ex_mem_cp0_reg_wdata ),

    .i_except_type      (id_ex2ex_except_type    ),
    .i_curr_inst_addr   (id_ex2ex_curr_inst_addr ),

    .o_except_type      (ex2ex_mem_except_type   ),
    .o_curr_inst_addr   (ex2ex_mem_curr_inst_addr),
    .o_delayslot_vld    (ex2ex_mem_delayslot_vld )
);

ex_mem ex_mem_inst (
    .i_clk               (i_clk                    ),
    .i_rst_n             (i_rst_n                  ),
    
    .i_ex_wen            (ex2ex_mem_alu_reg_wen    ),
    .i_ex_wdata          (ex2ex_mem_alu_reg_wdata  ),
    .i_ex_waddr          (ex2ex_mem_alu_reg_waddr  ),
    .i_stall             (pctrl2others_stall       ),
    
    .o_mem_wen           (ex_mem2mem_wen           ),
    .o_mem_wdata         (ex_mem2mem_wdata         ),
    .o_mem_waddr         (ex_mem2mem_waddr         ),
    
    .i_ex_hilo_wen       (ex2ex_mem_hilo_wen       ),
    .i_ex_hi             (ex2ex_mem_hi             ),
    .i_ex_lo             (ex2ex_mem_lo             ),
    .o_mem_hilo_wen      (ex_mem2mem_hilo_wen      ),
    .o_mem_hi            (ex_mem2mem_hi            ),
    .o_mem_lo            (ex_mem2mem_lo            ),
    
    .i_hilo_temp         (ex2ex_mem_hilo_temp      ),
    .i_cnt               (ex2ex_mem_cnt            ),
    .o_hilo_temp         (ex_mem2ex_hilo_temp      ), 
    .o_cnt               (ex_mem2ex_cnt            ),
        
    .i_ex_aluop          (ex2ex_mem_alu_op         ),
    .i_ex_mem_addr       (ex2ex_mem_addr           ),
    .i_ex_mem_data       (ex2ex_mem_data           ),
    
    .o_mem_aluop         (ex_mem2mem_aluop         ),
    .o_mem_addr          (ex_mem2mem_addr          ),
    .o_mem_data          (ex_mem2mem_data          ),

    .i_ex_cp0_reg_wen    (ex2ex_mem_cp0_reg_wen    ),
    .i_ex_cp0_reg_waddr  (ex2ex_mem_cp0_reg_waddr  ),
    .i_ex_cp0_reg_wdata  (ex2ex_mem_cp0_reg_wdata  ),

    .o_mem_cp0_reg_wen   (ex_mem2mem_cp0_reg_wen   ),
    .o_mem_cp0_reg_waddr (ex_mem2mem_cp0_reg_waddr ),
    .o_mem_cp0_reg_wdata (ex_mem2mem_cp0_reg_wdata ),

    .i_flush             (pctrl2others_flush       ),
    .i_ex_except_type    (ex2ex_mem_except_type    ),
    .i_ex_curr_inst_addr (ex2ex_mem_curr_inst_addr ),
    .i_ex_delayslot_vld  (ex2ex_mem_delayslot_vld  ),
    .o_mem_except_type   (ex_mem2mem_except_type   ),
    .o_mem_curr_inst_addr(ex_mem2mem_curr_inst_addr),
    .o_mem_delayslot_vld (ex_mem2mem_delayslot_vld )
);

mem mem_inst (
    .i_wen             (ex_mem2mem_wen           ),
    .i_waddr           (ex_mem2mem_waddr         ),
    .i_wdata           (ex_mem2mem_wdata         ),
       
    .o_wen             (mem2mem_wb_wen           ),
    .o_waddr           (mem2mem_wb_waddr         ),
    .o_wdata           (mem2mem_wb_wdata         ),
    
    .i_hilo_wen        (ex_mem2mem_hilo_wen      ),
    .i_hi              (ex_mem2mem_hi            ),
    .i_lo              (ex_mem2mem_lo            ),
    .o_hilo_wen        (mem2mem_wb_hilo_wen      ),
    .o_hi              (mem2mem_wb_hi            ),
    .o_lo              (mem2mem_wb_lo            ),
    
    .i_alu_op          (ex_mem2mem_aluop         ),
    .i_mem_addr        (ex_mem2mem_addr          ),
    .i_mem_data        (ex_mem2mem_data          ),
    
    .o_mem_addr        (o_ram_addr               ),
    .o_mem_wdata       (o_ram_data               ),
    .o_mem_we          (o_ram_we                 ),
    .o_mem_sel         (o_ram_sel                ),
    .o_mem_ce          (o_ram_ce                 ),
    .i_mem_rdata       (i_ram_data               ),

    .i_llbit           (llbit2mem_llbit          ),
    .i_wb_llbit_wen    (mem_wb2llbit_wen         ),
    .i_wb_llbit_data   (mem_wb2llbit_data        ),
 
    .o_llbit_wen       (mem2mem_llbit_wen        ),
    .o_llbit_data      (mem2mem_llbit_data       ),
 
    .i_cp0_reg_wen     (ex_mem2mem_cp0_reg_wen   ),
    .i_cp0_reg_waddr   (ex_mem2mem_cp0_reg_waddr ),
    .i_cp0_reg_wdata   (ex_mem2mem_cp0_reg_wdata ),
 
    .o_cp0_reg_wen     (mem2mem_wb_cp0_reg_wen   ),
    .o_cp0_reg_waddr   (mem2mem_wb_cp0_reg_waddr ),
    .o_cp0_reg_wdata   (mem2mem_wb_cp0_reg_wdata ),

    .i_except_type     (ex_mem2mem_except_type   ),
    .i_curr_inst_addr  (ex_mem2mem_curr_inst_addr),
    .i_delayslot_vld   (ex_mem2mem_delayslot_vld ),
    .i_wb_cp0_reg_wen  (mem_wb2cp0_reg_wen       ),
    .i_wb_cp0_reg_waddr(mem_wb2cp0_reg_waddr     ),
    .i_wb_cp0_reg_wdata(mem_wb2cp0_reg_wdata     ),
    .i_cp0_status      (cp02mem_status           ),
    .i_cp0_cause       (cp02mem_cause            ),
    .i_cp0_epc         (cp02mem_epc              ),
    .o_except_type     (mem2cp0_except_type      ),
    .o_curr_inst_addr  (mem2cp0_curr_inst_addr   ),
    .o_delayslot_vld   (mem2cp0_delayslot_vld    ),
    .o_cp0_epc         (mem2pctrl_cp0_epc        )
);

mem_wb mem_wb_inst (
    .i_clk              (i_clk                   ),
    .i_rst_n            (i_rst_n                 ),
       
    .i_mem_waddr        (mem2mem_wb_waddr        ),
    .i_mem_wdata        (mem2mem_wb_wdata        ),
    .i_mem_wen          (mem2mem_wb_wen          ),
    .i_stall            (pctrl2others_stall      ),
       
    .o_wb_waddr         (mem_wb2regfile_waddr    ),
    .o_wb_wdata         (mem_wb2regfile_wdata    ),
    .o_wb_wen           (mem_wb2regfile_wen      ),
       
    .i_mem_hilo_wen     (mem2mem_wb_hilo_wen     ),
    .i_mem_hi           (mem2mem_wb_hi           ),
    .i_mem_lo           (mem2mem_wb_lo           ),
    .o_wb_hilo_wen      (mem_wb2hilo_wen         ),
    .o_wb_hi            (mem_wb2hilo_hi          ),
    .o_wb_lo            (mem_wb2hilo_lo          ),
       
    .i_mem_llbit_wen    (mem2mem_llbit_wen       ),
    .i_mem_llbit_data   (mem2mem_llbit_data      ),
       
    .o_wb_llbit_wen     (mem_wb2llbit_wen        ),
    .o_wb_llbit_data    (mem_wb2llbit_data       ),

    .i_mem_cp0_reg_wen  (mem2mem_wb_cp0_reg_wen  ),
    .i_mem_cp0_reg_waddr(mem2mem_wb_cp0_reg_waddr),
    .i_mem_cp0_reg_wdata(mem2mem_wb_cp0_reg_wdata),

    .o_wb_cp0_reg_wen   (mem_wb2cp0_reg_wen      ),
    .o_wb_cp0_reg_waddr (mem_wb2cp0_reg_waddr    ),
    .o_wb_cp0_reg_wdata (mem_wb2cp0_reg_wdata    ) 
);

hilo_reg hilo_reg_reg (
    .i_clk    (i_clk          ),
    .i_rst_n  (i_rst_n        ),
    .i_wen    (mem_wb2hilo_wen),
    .i_hi     (mem_wb2hilo_hi ),
    .i_lo     (mem_wb2hilo_lo ),
    .o_hi     (hilo2ex_hi     ),
    .o_lo     (hilo2ex_lo     )   
);

pause_ctrl pause_ctrl_inst(
    .i_id_stallreq   (id2pctrl_streq       ),
    .i_ex_stallreq   (ex2pctrl_streq       ),
    .o_stall         (pctrl2others_stall   ),

    .i_cp0_epc       (mem2pctrl_cp0_epc    ), 
    .i_except_type   (mem2cp0_except_type  ),
    .o_new_pc        (pctrl2pc_new_pc      ),
    .o_flush         (pctrl2others_flush   )   
);

div # (
    .N_WIDTH( `N_REG )
)div_inst(
    .i_clk          (i_clk              ),
    .i_rst_n        (i_rst_n            ),
    .i_divsigned    (ex2div_divsigned   ),
    .i_divstart     (ex2div_divstart    ),
    .i_dividend     (ex2div_dividend    ),
    .i_divisor      (ex2div_divisor     ),
    .i_cancel       (pctrl2others_flush ),
    .o_quotient     (div2ex_quotient    ),
    .o_remainder    (div2ex_remainder   ),
    .o_done_vld     (div2ex_div_done    ),
    .o_ready        (div2ex_div_ready   )     
);

llbit_reg llbit_reg_inst(
    .i_clk     (i_clk             ),
    .i_rst_n   (i_rst_n           ),

    .i_flush   (pctrl2others_flush), // whether exception is occurred, 1 -> occurred
    .i_wen     (mem_wb2llbit_wen  ), 
    .i_llbit   (mem_wb2llbit_data ),
    .o_llbit   (llbit2mem_llbit   )
);

cp0 cp0_inst (
    .i_clk            (i_clk                 ),
    .i_rst_n          (i_rst_n               ),
 
    .i_r_addr         (ex2cp0_reg_raddr      ),
 
    .i_interrupt      (i_interrupt           ),
 
    .i_w_en           (mem_wb2cp0_reg_wen    ),
    .i_w_addr         (mem_wb2cp0_reg_waddr  ),   
    .i_w_data         (mem_wb2cp0_reg_wdata  ),
 
    .o_data           (cp02ex_data           ),

    .o_count          (),
    .o_compare        (),
    .o_status         (cp02mem_status        ),
    .o_cause          (cp02mem_cause         ),
    .o_epc            (cp02mem_epc           ),
    .o_config         (),
    .o_prid           (),
    .o_timer_interrupt(o_timer_interrupt     ),

    
    .i_except_type    (mem2cp0_except_type   ),
    .i_curr_inst_addr (mem2cp0_curr_inst_addr),
    .i_delayslot_vld  (mem2cp0_delayslot_vld ) 
);

endmodule