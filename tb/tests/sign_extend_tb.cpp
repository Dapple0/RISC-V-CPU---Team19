#include "base_testbench.h"
#include <cstdint>

unsigned int ticks = 0;

class SignExtendTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr = 0;
        top->ImmSrc = 0;
    }

    void loadInstr(uint32_t instr, uint8_t immSrc)
    {
        top->instr = instr;
        top->ImmSrc = immSrc;
        top->eval();
    }
};
// I-Type
TEST_F(SignExtendTestbench, IType)
{
    // Positive immediate = 5
    loadInstr(0x00500093, 0b000);
    EXPECT_EQ(top->ImmOp, 0x00000005);

    // Negative immediate = -1
    loadInstr(0xFFF00093, 0b000);
    EXPECT_EQ(top->ImmOp, 0xFFFFFFFF);
}

// S-Type
TEST_F(SignExtendTestbench, SType)
{
    // Positive immediate = 7
    loadInstr(0x001003A3, 0b001);
    EXPECT_EQ(top->ImmOp, 0x00000007);

    // Negative immediate = -4
    loadInstr(0xFE100E23, 0b001);
    EXPECT_EQ(top->ImmOp, 0xFFFFFFFC);
}


// B-TYPE
TEST_F(SignExtendTestbench, BType)
{
    // BEQ with branch offset = +8
    loadInstr(0x00000463, 0b010);
    EXPECT_EQ(top->ImmOp, 0x00000008);

    // BEQ with branch offset = -4
    loadInstr(0xFE000EE3, 0b010);
    EXPECT_EQ(top->ImmOp, 0xFFFFFFFC);
}


// U-TYPE
TEST_F(SignExtendTestbench, UType)
{
    // LUI with upper immediate = 0x12345
    loadInstr(0x123450B7, 0b011);
    EXPECT_EQ(top->ImmOp, 0x12345000);

    // LUI with upper immediate = 0xFEDCB
    loadInstr(0xFEDCB0B7, 0b011);
    EXPECT_EQ(top->ImmOp, 0xFEDCB000);
}


// J-TYPE 
TEST_F(SignExtendTestbench, JType)
{
    // JAL with jump offset = +16
    loadInstr(0x010000EF, 0b100);
    EXPECT_EQ(top->ImmOp, 0x00000010);

    // JAL with jump offset = -8
    loadInstr(0xFF9FF0EF, 0b100);
    EXPECT_EQ(top->ImmOp, 0xFFFFFFF8);
}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}