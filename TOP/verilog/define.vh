
`ifndef _DEFINE_SVH_
`define _DEFINE_SVH_ 
package DEFINE_PKG;
// controller
`define SA_NUM 6
`define INST_SIZE 13
`define FIFO_DEPTH 32 
//`define SRAM_DATA_SIZE 13
//`define SRAM_ADDR_SIZE 6
`define SRAM_ADDR_SIZE 10
`define POOL_COUNTER_WIDTH $clog2(`SA_NUM)+4 
`define SA_COUNTER_WIDTH $clog2(`SA_NUM)


// SA_ARRAY
`define SA_OUTPUT_WIDTH 13
`define SA_WB_WIDTH 16

`define DIMENSION 4
`define BIT_WIDTH 4

// SCAN
`define SCAN_WIDTH 130

typedef struct packed{
    logic [`SRAM_ADDR_SIZE-1:0]addr;
    logic [`SA_OUTPUT_WIDTH-1:0] data;
} FIFO_ENTRY_t;

typedef struct packed{
    logic sa_pe_en;
    logic [`DIMENSION-1:0] pool_en ;
    logic [`DIMENSION-1:0] pool_rd_en;
} POOL_PACKED_t;

typedef struct packed{
    logic [$clog2(`SA_NUM):0] sa_select;
    logic [`SA_NUM-1:0] load_weight_en_line;
} ARR_CTRL_PACKED;

//updated because innovus port name error Apr.4 by tgc
//typedef logic [`DIMENSION-1:0] SHIFT_OUT_t;
typedef struct packed{
    logic [`DIMENSION-1:0] in;

}SHIFT_OUT_t;

typedef struct packed{
    logic  [`SRAM_ADDR_SIZE-1:0] fifo_wr_addr ;
    logic  [`SA_OUTPUT_WIDTH-1:0]   pool_out ;

}SAA_WB_SANUM_PACKED_t;

//updated because innovus port name error Apr.4 by tgc
//typedef logic [`DIMENSION-1:0] POOL_RD_EN_t;
typedef struct packed{
    logic [`DIMENSION-1:0] pool_rd_en;

}POOL_RD_EN_t;

`define setup 3'b000
`define load_weight 3'b001
`define compute 3'b010
`define set_base_weight_addr 3'b011
`define set_base_input_addr 3'b100
`define set_base_output_addr 3'b101

`define v_mode 1
`define h_mode 0

`define bit2_mode 0
`define bit4_mode 1

`define idle 3'b000
`define pool0_busy 3'b001
`define pool1_busy 3'b010
`define both_busy_pool0 3'b011
`define both_busy_pool1 3'b100
`define idle_pool0 3'b101
`define idle_pool1 3'b110

typedef bit [`INST_SIZE-1:0] inst_t;
typedef bit [`SRAM_ADDR_SIZE-1:0] sram_addr_t;
endpackage

`endif
