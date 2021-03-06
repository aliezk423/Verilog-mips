`include "instructionDef.v"
`timescale  1ns / 1ps

module ctrl(clk,rst,done,instr,aluout,regdst,alusrc,regwrite,memwrite,extop,aluop,npcop,memtoreg,IRwr,PCwr,mdop);
    input clk,rst,done;
    input [31:0] instr;
    input [31:0] aluout;
    output reg[1:0] regdst;
    output reg alusrc;
    output reg regwrite;
    output reg memwrite;
    output reg [1:0] extop;
    output reg [3:0] aluop;
    output reg [1:0] npcop;
    output reg [2:0] memtoreg;
    output reg IRwr,PCwr;
    output reg [2:0] mdop;

    parameter Fetch = 4'b0000,
              DCD = 4'b0001,
              MA = 4'b0010,
              MR = 4'b0011,
              MemWB = 4'b0100,
              MW = 4'b0101,
              Exe = 4'b0110,
              WB = 4'b0111,
              Branch = 4'b1000,
              Jmp = 4'b1001,
              Wait = 4'b1010;
    
    reg[3:0] state;
    reg[3:0] nextState;

    wire RType;   
    wire IType;   
    wire BrType;  
    wire JType;   
    wire LdType;  
    wire StType;  
    wire MemType; 
	
    assign RType = (instr[31:26] == `RTYPE_OP && instr[5:0] != `JR_FUNCT&&instr[5:0]!=`JALR_FUNCT);
    assign IType  = (instr[31:26] == `ORI_OP||instr[31:26] == `LUI_OP||instr[31:26] == `ADDI_OP||instr[31:26] == `ADDIU_OP||instr[31:26] == `SLTI_OP||instr[31:26] == `ANDI_OP|| instr[31:26] == `XORI_OP|| instr[31:26] == `SLTIU_OP);
    assign BrType = (instr[31:26] == `BEQ_OP|| instr[31:26] == `BNE_OP|| instr[31:26] == `BLEZ_OP|| instr[31:26] == `BGTZ_OP|| instr[31:26] == `TWOBZ_OP);
    assign JType  = (instr[31:26] == `JAL_OP||instr[31:26] == `J_OP||(instr[31:26] == `RTYPE_OP&&instr[5:0] == `JR_FUNCT)||(instr[31:26] == `RTYPE_OP&&instr[5:0] == `JALR_FUNCT));
    assign LdType = (instr[31:26] == `LW_OP||instr[31:26] == `LB_OP||instr[31:26] == `LH_OP||instr[31:26] == `LBU_OP||instr[31:26] == `LHU_OP);
    assign StType = (instr[31:26] == `SW_OP||instr[31:26] == `SB_OP||instr[31:26] == `SH_OP);
    assign MemType = LdType || StType;

    always @(posedge clk)
    begin
        if(rst)
            state<=0;
        else
            state<=nextState;
    end

    always @(*)
    begin
        case(state)
            Fetch:nextState=DCD;
            DCD:
            begin
                if(MemType)
                    nextState=MA;
                else if(RType)
                begin
                    if(instr[5:0]==`MULT_FUNCT||instr[5:0]==`MULTU_FUNCT||instr[5:0]==`DIV_FUNCT||instr[5:0]==`DIVU_FUNCT)
                        nextState=Wait;
                    else
                        nextState=Exe;
                end
                else if(IType)
                    nextState=Exe;
                else if(BrType)
                    nextState=Branch;
                else if(JType)
                    nextState=Jmp;
                else nextState=Fetch;
            end
            MA:
            begin
                if(LdType)
                    nextState=MR;
                else
                    nextState=MW;
            end
            Wait:
            begin
                if(done==1'b1)
                    nextState=Fetch;
                else
                    nextState=Wait;
            end
            Exe:
                nextState=WB;
            Branch:
                nextState=Fetch;
            Jmp:
                nextState=Fetch;
            MR:
                nextState=MemWB;
            MW:
                nextState=Fetch;
            WB:
                nextState=Fetch;
            MemWB:
                nextState=Fetch;
        endcase
    end
    //fsm

    always @(*)
    begin
        case(state)
            Fetch:
            begin
                IRwr<=1;
                PCwr<=1;
                regdst<=2'b00;
                alusrc<=0;
                regwrite<=0;
                memwrite<=0;
                extop<=2'b00;
                aluop<=4'b0000;
                npcop<=2'b00;
                memtoreg<=3'b000;
                mdop<=3'b110;
            end
            DCD:
            begin
                IRwr<=0;
                PCwr<=0;
                regwrite<=0;
                memwrite<=0;
                mdop<=3'b110;
                if(RType)
                begin
                regdst<=2'b01;
                alusrc<=0;
                extop<=2'b00;
                npcop<=2'b00;
                    case(instr[5:0])
                        `ADDU_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `SUBU_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                        end
                        `SLT_FUNCT:
                        begin
                            aluop<=4'b0011;
                            memtoreg<=3'b000;
                        end
                        `ADD_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `SUB_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                        end
                        `SLL_FUNCT:
                        begin
                            aluop<=4'b0100;
                            memtoreg<=3'b000;
                        end
                        `SRL_FUNCT:
                        begin
                            aluop<=4'b0101;
                            memtoreg<=3'b000;
                        end
                        `SRA_FUNCT:
                        begin
                            aluop<=4'b0110;
                            memtoreg<=3'b000;
                        end
                        `SLLV_FUNCT:
                        begin
                            aluop<=4'b0111;
                            memtoreg<=3'b000;
                        end
                        `SRLV_FUNCT:
                        begin
                            aluop<=4'b1000;
                            memtoreg<=3'b000;
                        end
                        `SRAV_FUNCT:
                        begin
                            aluop<=4'b1001;
                            memtoreg<=3'b000;
                        end
                        `AND_FUNCT:
                        begin
                            aluop<=4'b1010;
                            memtoreg<=3'b000;
                        end
                        `OR_FUNCT:
                        begin
                            aluop<=4'b0010;
                            memtoreg<=3'b000;
                        end
                        `XOR_FUNCT:
                        begin
                            aluop<=4'b1011;
                            memtoreg<=3'b000;
                        end
                        `NOR_FUNCT:
                        begin
                            aluop<=4'b1100;
                            memtoreg<=3'b000;
                        end
                        `MULT_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `MULTU_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `DIV_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `DIVU_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `MFHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b011;
                        end
                        `MFLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b100;
                        end
                        `MTHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        `MTLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                        end
                        default: ;
                    endcase
                end
                else if(IType)
                    begin
                    case(instr[31:26])
                        `ORI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b00;
                            aluop<=4'b0010;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `LUI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b10;
                            aluop<=4'b0000;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `ADDI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b01;
                            aluop<=4'b0000;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `ADDIU_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b01;
                            aluop<=4'b0000;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `SLTI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b01;
                            aluop<=4'b0011;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `ANDI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b00;
                            aluop<=4'b1010;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end 
                        `XORI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b00;
                            aluop<=4'b1011;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `SLTIU_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b01;
                            aluop<=4'b1110;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        default: ;
                    endcase
                    end
                else if(BrType)
                    begin
                        regdst<=2'b00;
                        alusrc<=0;
                        extop<=2'b00;
                        npcop<=2'b01;
                        memtoreg<=3'b000;
                        if(instr[31:26]==`BEQ_OP||instr[31:26]==`BNE_OP)
                            aluop<=4'b0001;
                        else
                            aluop<=4'b1101;
                    end
                else if(JType)
                    begin
                        if(instr[31:26]==`J_OP)
                            begin
                                regdst<=2'b00;
                                alusrc<=0;
                                extop<=2'b00;
                                aluop<=4'b0000;
                                npcop<=2'b10;
                                memtoreg<=3'b000;
                            end
                        else if(instr[31:26]==`JAL_OP)
                            begin
                                regdst<=2'b10;
                                alusrc<=0;
                                extop<=2'b00;
                                aluop<=4'b0000;
                                npcop<=2'b10;
                                memtoreg<=3'b010;
                            end
                        else if(instr[5:0]==`JR_FUNCT)
                            begin
                                regdst<=2'b00;
                                alusrc<=0;
                                extop<=2'b00;
                                aluop<=4'b0000;
                                npcop<=2'b11;
                                memtoreg<=3'b000;
                            end
                        else
                            begin
                                regdst<=2'b01;
                                alusrc<=0;
                                extop<=2'b00;
                                aluop<=4'b0000;
                                npcop<=2'b11;
                                memtoreg<=3'b010;
                            end
                    end
                else if(LdType)
                    begin
                        regdst<=2'b00;
                        alusrc<=1;
                        extop<=2'b01;
                        aluop<=4'b0000;
                        npcop<=2'b00;
                        memtoreg<=3'b001;
                    end
                else
                    begin
                        mdop<=3'b110;
                        regdst<=2'b00;
                        alusrc<=1;
                        extop<=2'b01;
                        aluop<=4'b0000;
                        npcop<=2'b00;
                        memtoreg<=3'b000;
                    end
            end
            MA:
            begin
                mdop<=3'b110;
                IRwr<=0;
                PCwr<=0;
                regwrite<=0;
                memwrite<=0;
                aluop<=4'b0000;
                if(LdType)
                    begin
                        regdst<=2'b00;
                        alusrc<=1;
                        extop<=2'b01;
                        npcop<=2'b00;
                        memtoreg<=3'b001;
                    end
                else
                    begin
                        regdst<=2'b00;
                        alusrc<=1;
                        extop<=2'b01;
                        npcop<=2'b00;
                        memtoreg<=3'b000;
                    end
            end
            MR:
            begin
                mdop<=3'b110;
                IRwr<=0;
                PCwr<=0;
                regdst<=2'b00;
                alusrc<=1;
                regwrite<=0;
                memwrite<=0;
                extop<=2'b01;
                aluop<=4'b0000;
                npcop<=2'b00;
                memtoreg<=3'b001;
            end
            MemWB:
            begin
                mdop<=3'b110;
                IRwr<=0;
                PCwr<=0;
                regdst<=2'b00;
                alusrc<=1;
                regwrite<=1;
                memwrite<=0;
                extop<=2'b01;
                aluop<=4'b0000;
                npcop<=2'b00;
                memtoreg<=3'b001;
            end
            MW:
            begin
                mdop<=3'b110;
                IRwr<=0;
                PCwr<=0;
                begin
                    regdst<=2'b00;
                    alusrc<=1;
                    regwrite<=0;
                    memwrite<=1;
                    extop<=2'b01;
                    aluop<=4'b0000;
                    npcop<=2'b00;
                    memtoreg<=3'b000;
                end
            end
            Exe:
            begin
                IRwr<=0;
                PCwr<=0;
                regwrite<=0;
                memwrite<=0;
                if(RType)
                begin
                regdst<=2'b01;
                alusrc<=0;
                extop<=2'b00;
                npcop<=2'b00;
                    case(instr[5:0])
                        `ADDU_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SUBU_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLT_FUNCT:
                        begin
                            aluop<=4'b0011;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `ADD_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SUB_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLL_FUNCT:
                        begin
                            aluop<=4'b0100;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRL_FUNCT:
                        begin
                            aluop<=4'b0101;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRA_FUNCT:
                        begin
                            aluop<=4'b0110;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLLV_FUNCT:
                        begin
                            aluop<=4'b0111;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRLV_FUNCT:
                        begin
                            aluop<=4'b1000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRAV_FUNCT:
                        begin
                            aluop<=4'b1001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `AND_FUNCT:
                        begin
                            aluop<=4'b1010;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `OR_FUNCT:
                        begin
                            aluop<=4'b0010;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `XOR_FUNCT:
                        begin
                            aluop<=4'b1011;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `NOR_FUNCT:
                        begin
                            aluop<=4'b1100;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `MFHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b011;
                            mdop<=3'b110;
                        end
                        `MFLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b100;
                            mdop<=3'b110;
                        end
                        `MTHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b100;
                        end
                        `MTLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b101;
                        end
                        default: ;
                    endcase
                end
                else
                begin
                    mdop<=3'b110;
                    case(instr[31:26])
                        `ORI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b00;
                                aluop<=4'b0010;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                        `LUI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b10;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                        `ADDI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                        `ADDIU_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                        `SLTI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0011;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                        `ANDI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b00;
                            aluop<=4'b1010;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end 
                        `XORI_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b00;
                            aluop<=4'b1011;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        `SLTIU_OP:
                        begin
                            regdst<=2'b00;
                            alusrc<=1;
                            extop<=2'b01;
                            aluop<=4'b1110;
                            npcop<=2'b00;
                            memtoreg<=3'b000;
                        end
                        default: ;
                    endcase
                end
            end
            Wait:
            begin
                regdst<=2'b00;
                alusrc<=0;
                regwrite<=0;
                memwrite<=0;
                extop<=2'b00;
                aluop<=4'b0000;
                npcop<=2'b00;
                memtoreg<=2'b00;
                IRwr<=0;
                PCwr<=0;
                case(instr[5:0])
                `MULT_FUNCT:
                begin
                    mdop<=3'b000;
                end
                `MULTU_FUNCT:
                begin
                    mdop<=3'b001;
                end
                `DIV_FUNCT:
                begin
                    mdop<=3'b010;
                end
                `DIVU_FUNCT:
                begin
                    mdop<=3'b011;
                end
                default : ;  
                endcase                  
            end
            WB:
            begin
                if(instr[5:0]==`MTHI_FUNCT||instr[5:0]==`MTLO_FUNCT)
                    regwrite<=0;
                else
                    regwrite<=1;
                IRwr<=0;
                PCwr<=0;
                memwrite<=0;
                if(RType)
                begin
                regdst<=2'b01;
                alusrc<=0;
                extop<=2'b00;
                npcop<=2'b00;
                    case(instr[5:0])
                        `ADDU_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SUBU_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLT_FUNCT:
                        begin
                            aluop<=4'b0011;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `ADD_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SUB_FUNCT:
                        begin
                            aluop<=4'b0001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLL_FUNCT:
                        begin
                            aluop<=4'b0100;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRL_FUNCT:
                        begin
                            aluop<=4'b0101;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRA_FUNCT:
                        begin
                            aluop<=4'b0110;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SLLV_FUNCT:
                        begin
                            aluop<=4'b0111;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRLV_FUNCT:
                        begin
                            aluop<=4'b1000;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `SRAV_FUNCT:
                        begin
                            aluop<=4'b1001;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `AND_FUNCT:
                        begin
                            aluop<=4'b1010;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `OR_FUNCT:
                        begin
                            aluop<=4'b0010;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `XOR_FUNCT:
                        begin
                            aluop<=4'b1011;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `NOR_FUNCT:
                        begin
                            aluop<=4'b1100;
                            memtoreg<=3'b000;
                            mdop<=3'b110;
                        end
                        `MFHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b011;
                            mdop<=3'b110;
                        end
                        `MFLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b100;
                            mdop<=3'b110;
                        end
                        `MTHI_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b100;
                        end
                        `MTLO_FUNCT:
                        begin
                            aluop<=4'b0000;
                            memtoreg<=3'b000;
                            mdop<=3'b101;
                        end
                        default: ;
                    endcase
                end
                else if(IType)
                    begin
                        mdop<=3'b110;
                        case(instr[31:26])
                            `ORI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b00;
                                aluop<=4'b0010;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `LUI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b10;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `ADDI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `ADDIU_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0000;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `SLTI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b0011;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `ANDI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b00;
                                aluop<=4'b1010;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end 
                            `XORI_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b00;
                                aluop<=4'b1011;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            `SLTIU_OP:
                            begin
                                regdst<=2'b00;
                                alusrc<=1;
                                extop<=2'b01;
                                aluop<=4'b1110;
                                npcop<=2'b00;
                                memtoreg<=3'b000;
                            end
                            default: ;
                        endcase
                    end
            end
            Branch:
                begin
                    mdop<=3'b110;
                    IRwr<=0;
                    regdst<=2'b00;
                    alusrc<=0;
                    regwrite<=0;
                    memwrite<=0;
                    extop<=2'b00;
                    memtoreg<=3'b000;
                    if(instr[31:26]==`BEQ_OP)
                    begin
                        aluop<=4'b0001;
                        if(aluout==0)
                        npcop<=2'b01;
                        else
                        npcop<=2'b00;
                        if(aluout==0)
                        PCwr<=1;
                        else
                            PCwr<=0;
                    end
                    else if(instr[31:26]==`BNE_OP)
                    begin
                        aluop<=4'b0001;
                        if(aluout!=0)
                        npcop<=2'b01;
                        else
                        npcop<=2'b00;
                        if(aluout!=0)
                        PCwr<=1;
                        else
                            PCwr<=0;
                    end
                    else
                    begin
                        aluop<=4'b1101;
                        if(instr[31:26]==`BLEZ_OP)
                        begin
                            if(aluout==32'b0||aluout[31]==1'b1)
                            npcop<=2'b01;
                            else
                            npcop<=2'b00;
                            if(aluout==32'b0||aluout[31]==1'b1)
                            PCwr<=1;
                            else
                                PCwr<=0;
                        end
                        else if(instr[31:26]==`BGTZ_OP)
                        begin
                            if(aluout[31]==1'b0&&aluout!=32'b0)
                            npcop<=2'b01;
                            else
                            npcop<=2'b00;
                            if(aluout[31]==1'b0&&aluout!=32'b0)
                            PCwr<=1;
                            else
                                PCwr<=0;
                        end
                        else if(instr[20:16]==`BLTZ_BZ)
                        begin
                            if(aluout[31]==1'b1)
                            npcop<=2'b01;
                            else
                            npcop<=2'b00;
                            if(aluout[31]==1'b1)
                            PCwr<=1;
                            else
                                PCwr<=0;
                        end
                        else
                        begin
                            if(aluout[31]==1'b0)
                            npcop<=2'b01;
                            else
                            npcop<=2'b00;
                            if(aluout==1'b0)
                            PCwr<=1;
                            else
                                PCwr<=0;
                        end
                    end
                end 
            Jmp:
                begin
                    mdop<=3'b110;
                    extop<=2'b00;
                    PCwr<=1;
                    IRwr<=0;
                    if(instr[31:26]==`J_OP)
                    begin
                        regdst<=2'b00;
                        alusrc<=0;
                        regwrite<=0;
                        memwrite<=0;
                        aluop<=4'b0000;
                        npcop<=2'b10;
                        memtoreg<=3'b000;
                    end
                    else if(instr[31:26]==`JAL_OP)
                    begin
                        regdst<=2'b10;
                        alusrc<=0;
                        regwrite<=1;
                        memwrite<=0;
                        aluop<=4'b0000;
                        npcop<=2'b10;
                        memtoreg<=3'b010;
                    end
                    else if(instr[5:0]==`JR_FUNCT)
                        begin
                            regdst<=2'b00;
                            alusrc<=0;
                            regwrite<=0;
                            memwrite<=0;
                            aluop<=4'b0000;
                            npcop<=2'b11;
                            memtoreg<=3'b000;
                        end
                    else
                        begin
                            regdst<=2'b01;
                            alusrc<=0;
                            regwrite<=1;
                            memwrite<=0;
                            aluop<=4'b0000;
                            npcop<=2'b11;
                            memtoreg<=3'b010;
                        end
                end
                default: ;    
        endcase
    end
endmodule