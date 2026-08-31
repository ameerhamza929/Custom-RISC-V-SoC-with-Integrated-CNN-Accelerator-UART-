`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 

//////////////////////////////////////////////////////////////////////////////////


module pipelineprocessor(
    input clk,
    input rst,
    input start,
    output wire MemWriteM,
    output wire [31:0] ALU_resultM,
    output wire [31:0] rdata2M,
    input wire [31:0] read_data_mem
    
    );
    
   wire [31:0] PC;
   wire reg_write;
   wire [4:0]rs1;
   wire [4:0]rs2;
   wire [4:0]rd;
   wire [31:0]wr;
   wire [31:0]rdata1;
   wire [31:0]rdata2;
   wire [6:0] opcode;
   wire [6:0] func7;
   wire [2:0] func3;
   wire ALUSrc;  
   wire MemRead;
   wire MemWrite;
   wire MemtoReg; 
   (* mark_debug = "true" *) wire [31:0]inst; 
   wire [11:0] imm; 
   wire [12:0] branch_imm; 
    wire branch;
    wire [1:0] ALU_op;
//    wire jump;
    wire PCsrcE;
    wire zero;
    wire [31:0]PCnext;
    wire [31:0] bPC;
    wire [20:0] jump_imm;
    wire jump;
    
    wire RegWriteM;
    wire [1:0]ResultSrcM;
    
    
    wire [31:0] WriteDataM;
    wire [4:0] RdM;
    wire [31:0] PCplus4M; 
    
    
    wire RegWriteW;
    wire [1:0]ResultSrcW;
    wire [31:0] read_data_mem_W;
    wire [4:0]RdW;
    wire [31:0] PCplus4W;
    wire [31:0] ALU_resultW;
    
   wire stallF;
   wire stallD;
   wire FlushE;
   wire FlushD;
   
   wire [6:0] opcodeW;
   
    
    assign PCsrcE =  JumpE|(BranchE & zero);
    
    
    
    wire [31:0] PCplus4F;
   
  Mux2x1 #(
     .WIDTH (32)
  ) mux3(
     .A(PCplus4F),
     .B(bPC),
     .sel(PCsrcE),
     .out (PCnext)
     ); 
    
   
   PCreg PCed(
       .clk(clk),
       .rst(rst),
       .en(!stallF),
       .PCin(PCnext),
       .PCout(PC)
    );
    
    
    
     PC add(
        .PCin(PC),
        .start(start),
        .count(PCplus4F)
        );
        
    Inst_mem instmem(
       .PC(PC),
       .start(start),
       .inst(inst)    
    );
    
   wire [31:0] InstrD;
   wire [31:0] PCD;
   wire [31:0] PCplus4D;
   IF_ID ifid(
     .clk(clk),
     .rst(rst),
     .en(!stallD),
     .flashD(FlushD),
     .InstrF(inst),   
     .PCF(PC),   
     .PCplus4F(PCplus4F), 
     .InstrD(InstrD),
     .PCD(PCD),
     .PCplus4D(PCplus4D) 
    );
    
    wire [1:0] ResultSrc;
    
    
    Decoder decode(
      .inst(InstrD),
      .opcode(opcode),
      .rd(rd),
      .rs1(rs1),
      .rs2(rs2),
      .func7(func7),
      .func3(func3),
      .imm(imm),
      .branch_imm(branch_imm),
      .jump_imm(jump_imm)
        );
    
    Control controller(
        .opcode(opcode),
        .Regwrite(reg_write),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALU_op(ALU_op),
        .ResultSrc(ResultSrc),
        .branch(branch),
        .jump(jump)
     );
    
    Register_File Regfile (
        .clk(clk),
        .rst(rst),
        .opcode(opcodeW),
        .reg_write(RegWriteW),
        .rs1(rs1),
        .rs2(rs2),
        .rd(RdW),
        .wr(wr),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    
   wire [31:0] srcA;
   wire [31:0] signextended;
   
   
   
  Signextend extend(
     .imm(imm),
     .branch_imm(branch_imm),
     .jump_imm(jump_imm),
     .branch(branch),
     .jump(jump),
     .signextended(signextended)
    );
    
    wire [2:0] ALU_Ctrl;
    
     ALU_Control Ctrl (
        .ALU_op(ALU_op),
        .op5(opcode[5]),
        .func3(func3),
        .func7(func7),
        .ALU_Ctrl(ALU_Ctrl)
    );
   
   
    wire RegWriteE;
    wire [1:0]ResultSrcE;
    wire MemWriteE;
    wire JumpE;
    wire BranchE;
    wire [2:0]ALUControlE;
    wire ALUSrcE;
    wire [31:0]rdata1E;
    wire [31:0]rdata2E;
    wire [31:0]PCE;
    wire [4:0]rs1E;
    wire [4:0]rs2E;
    wire [4:0]rdE;
    wire [31:0] ImmExtE;
    wire [31:0] PCplus4E;
    wire [6:0] opcodeE;
   
  ID_EX idex(
   .clk(clk),
   .rst (rst),
   .en  (!FlushE),
   .RegWriteD(reg_write),
   .ResultSrcD(ResultSrc),
   .MemWriteD (MemWrite),
   .JumpD(jump),
   .BranchD(branch),
   .ALUControlD(ALU_Ctrl),
   .ALUSrcD(ALUSrc),
   .rdata1(rdata1),
   .rdata2(rdata2),
   .PCD(PCD),
   .rs1D(rs1),
   .rs2D(rs2),
   .rdD(rd),
   .ImmExtD(signextended),
   .PCplus4D(PCplus4D),
   .opcode(opcode),
   .RegWriteE(RegWriteE),
   .ResultSrcE(ResultSrcE),
   .MemWriteE(MemWriteE),
   .JumpE(JumpE),
   .BranchE(BranchE),
   .ALUControlE(ALUControlE),
   .ALUSrcE(ALUSrcE),
   .rdata1E(rdata1E),
   .rdata2E(rdata2E),
   .PCE(PCE),
   .rs1E(rs1E),
   .rs2E(rs2E),
   .rdE(rdE),
   .ImmExtE(ImmExtE),
   .PCplus4E(PCplus4E),
   .opcodeE(opcodeE)
  );
   
   
   wire [1:0] forwardAE;
   wire [1:0] forwardBE;
 
// assign srcA = rdata1E;
   
   wire [31:0] srcB;
   
   wire [31:0] ALU_result;  
   
 Hazard_Unit hazards(
     .rs1E(rs1E),
     .rdM(RdM),
     .RegWriteM(RegWriteM),
     .rdW(RdW),
     .RegWriteW(RegWriteW),
     .rs2E(rs2E),
     .ResultSrcE0(ResultSrcE[0]),
     .rs1(rs1),
     .rs2(rs2),
     .rdE(rdE),
     .PCSrc(PCsrcE),
     .stallF(stallF),
     .stallD(stallD),
     .FlushD(FlushD),
     .FlushE(FlushE),
     .ForwardAE(forwardAE),
     .ForwardBE(forwardBE)
    );
   
 
 mux3x1 Forward1(
    .a(rdata1E),
    .b(wr),
    .c(ALU_resultM),
    .sel(forwardAE),
    .out(srcA)
    );
 wire [31:0] srcB_temp;
 
  mux3x1 Forward2(
    .a(rdata2E),
    .b(wr),
    .c(ALU_resultM),
    .sel(forwardBE),
    .out(srcB_temp)
    );
   
   
 Mux2x1 #(
  .WIDTH (32)
    ) mux1(
        .A(srcB_temp),
        .B(ImmExtE),
        .sel(ALUSrcE),
        .out (srcB)
        );
       
   
  
  
  ALU alu(
     .srcA(srcA),
     .srcB(srcB),
     .ALU_Ctrl(ALUControlE),
     .ALU_result(ALU_result),
     .zero(zero)
    );
    
    
  PCtargeradder Adder(
       .A(PCE),
       .B(ImmExtE),
       .result(bPC)
    );
    
      
      wire [6:0] opcodeM;
    
    
 EX_MEM ex_mem(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .ALU_result(ALU_result),
    .WriteDataE(srcB_temp),
    .RdE(rdE),
    .PCplus4E(PCplus4E),
    .rdata2E(rdata2E),
    .opcodeE(opcodeE),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .MemWriteM(MemWriteM),
    .ALU_resultM(ALU_resultM),
    .WriteDataM(WriteDataM),
    .RdM(RdM),
    .PCplus4M(PCplus4M),
    .rdata2M(rdata2M),
    .opcodeM(opcodeM)
);   
 
    
// Data_mem Datamemory(
//   .clk(clk),
//   .rst(rst),
//   .mem_read(1'b1),
//   .mem_write(MemWriteM),
//   .addr(ALU_resultM),
//   .write_data(rdata2M),
//   .read_data (read_data_mem)  
//    );
    
    
    
    
    
    MEM_WB mem_wb_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .read_data_mem(read_data_mem),
        .RdM(RdM),
        .PCplus4M(PCplus4M),
        .ALU_resultM(ALU_resultM),
        .opcodeM(opcodeM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .read_data_mem_W(read_data_mem_W),
        .RdW(RdW),
        .PCplus4W(PCplus4W),
        .ALU_resultW(ALU_resultW),
        .opcodeW(opcodeW)
  );
    
    
    
   mux3x1 aluoutmux(
    .a(ALU_resultW),
    .b(read_data_mem),
    .c(PCplus4W),
    .sel(ResultSrcW),
    .out(wr)
    );
    
    
    
//    Mux2x1 #(
//        .WIDTH (32)
//    ) mux2(
//        .A(ALU_result),
//        .B(read_data_mem),
//        .sel(ResultSrc),
//        .out (wr)
//        );
    
    
endmodule
