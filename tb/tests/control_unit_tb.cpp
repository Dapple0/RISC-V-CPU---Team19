
#include "base_testbench.h"
#include <cstdint>


unsigned int ticks = 0;

class ControlTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr = 0;
        top->EQ = 0;
    }

    void loadInstr(uint32_t instr)
    {
        top->instr = instr;
        top->eval();
    }
};

TEST_F(ControlTestbench, ITypeALU) {
    // ADDI x1, x0, 1
    loadInstr(0b00000000000100000000000010010011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // ANDI x1, x0, 1
    loadInstr(0b00000000000100000111000010010011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b011);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // SLLI x1, x0, 1
    loadInstr(0b00000000000100000001000010010011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b100);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // SRLI x1, x0, 1
    loadInstr(0b00000000000100000101000010010011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b101);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);
}
TEST_F(ControlTestbench, RTypeALU)
{
    // ADD x1, x0, x1
    loadInstr(0b00000000000100000000000010110011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 0);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // XOR x1, x0, x1
    loadInstr(0b00000000000100000100000010110011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b010);
    EXPECT_EQ(top->ALUsrc, 0);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);
}


// BRANCH INSTRUCTIONS
// BEQ, BNE

TEST_F(ControlTestbench, Branches)
{
    // BEQ: registers are equal
    top->EQ = 1;
    loadInstr(0b00000000000100000000000001100011);

    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ALUctrl, 0b001);
    EXPECT_EQ(top->ALUsrc, 0);
    EXPECT_EQ(top->ImmSrc, 0b010);
    EXPECT_EQ(top->PCsrc, 1);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // BEQ: registers are NOT equal
    top->EQ = 0;
    top->eval();

    EXPECT_EQ(top->PCsrc, 0);

    // BNE: registers are NOT equal
    top->EQ = 0;
    loadInstr(0b00000000000100000001000001100011);

    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ALUctrl, 0b001);
    EXPECT_EQ(top->ALUsrc, 0);
    EXPECT_EQ(top->ImmSrc, 0b010);
    EXPECT_EQ(top->PCsrc, 1);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b00);

    // BNE: registers are equal
    top->EQ = 1;
    top->eval();

    EXPECT_EQ(top->PCsrc, 0);
}


// U-TYPE INSTRUCTIONS
// LUI

TEST_F(ControlTestbench, UpperImmediate)
{

    // LUI x1, 1
    loadInstr(0b00000000000000000001000010110111);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 0);
    EXPECT_EQ(top->ImmSrc, 0b011);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b11);
}


// LOAD INSTRUCTIONS
// LBU

TEST_F(ControlTestbench, Loads)
{
    // LBU x1, 1(x0)
    loadInstr(0b00000000000100000100000010000011);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b01);
}


// STORE INSTRUCTIONS
// SB

TEST_F(ControlTestbench, Stores)
{
    // SB x1, 1(x0)
    loadInstr(0b00000000000100000000000010100011);

    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b001);
    EXPECT_EQ(top->PCsrc, 0);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->ResultSrc, 0b00);
}


// JUMP INSTRUCTIONS
// JAL, JALR

TEST_F(ControlTestbench, Jumps)
{
    // JAL
    loadInstr(0b00000000000100000000000011101111);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b100);
    EXPECT_EQ(top->PCsrc, 1);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b10);

    // JALR
    loadInstr(0b00000000000000001000000011100111);

    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUctrl, 0b000);
    EXPECT_EQ(top->ALUsrc, 1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->PCsrc, 1);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ResultSrc, 0b10);
}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
