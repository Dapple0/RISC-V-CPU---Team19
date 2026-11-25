// Verifies the results of the data memory, exits with a 0 on success.

#include <cstdio>

#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class DataMemTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->A = 0;
        top->WD = 0;
        top->WE = 0;
        top->funct3 = 0b010;
        // output: RD
    }
};

TEST_F(DataMemTestbench, StoreWordLoadWordTest)
{
    // sw 0xCAFEBABE to 0x100
    top->A = 0x100;
    top->WD = 0xCAFEBABE;
    top->WE = 1;
    top->funct3 = 0b010;
    runSimulation(1);

    // lw from 0x100
    top->WE = 0;
    top->eval();

    EXPECT_EQ(top->RD, 0xCAFEBABE);
}

TEST_F(DataMemTestbench, LittleEndianTest)
{
    // sw 0x11223344 to 0x100
    top->A = 0x100;
    top->WD = 0x11223344;
    top->WE = 1;
    top->funct3 = 0b010;
    runSimulation(1);

    // lbu each byte: lowest address holds the lowest byte
    top->WE = 0;
    top->funct3 = 0b100;

    top->A = 0x100;
    top->eval();
    EXPECT_EQ(top->RD, 0x44);

    top->A = 0x101;
    top->eval();
    EXPECT_EQ(top->RD, 0x33);

    top->A = 0x102;
    top->eval();
    EXPECT_EQ(top->RD, 0x22);

    top->A = 0x103;
    top->eval();
    EXPECT_EQ(top->RD, 0x11);
}

TEST_F(DataMemTestbench, StoreByteTest)
{
    // sw 0xAABBCCDD to 0x200
    top->A = 0x200;
    top->WD = 0xAABBCCDD;
    top->WE = 1;
    top->funct3 = 0b010;
    runSimulation(1);

    // sb 0x123456FF to 0x201: only FF is written
    top->A = 0x201;
    top->WD = 0x123456FF;
    top->funct3 = 0b000;
    runSimulation(1);

    // lw from 0x200
    top->A = 0x200;
    top->WE = 0;
    top->funct3 = 0b010;
    top->eval();

    EXPECT_EQ(top->RD, 0xAABBFFDD);
}

TEST_F(DataMemTestbench, LoadByteSignedTest)
{
    // sb 0x80 to 0x300
    top->A = 0x300;
    top->WD = 0x80;
    top->WE = 1;
    top->funct3 = 0b000;
    runSimulation(1);

    // lb: sign-extended
    top->WE = 0;
    top->funct3 = 0b000;
    top->eval();
    EXPECT_EQ(top->RD, 0xFFFFFF80);

    // lbu: zero-extended
    top->funct3 = 0b100;
    top->eval();
    EXPECT_EQ(top->RD, 0x00000080);
}

TEST_F(DataMemTestbench, HalfWordTest)
{
    // sh 0xFFFF8001 to 0x400: only 0x8001 is written
    top->A = 0x400;
    top->WD = 0xFFFF8001;
    top->WE = 1;
    top->funct3 = 0b001;
    runSimulation(1);

    // lhu: zero-extended
    top->WE = 0;
    top->funct3 = 0b101;
    top->eval();
    EXPECT_EQ(top->RD, 0x00008001);

    // lh: sign-extended
    top->funct3 = 0b001;
    top->eval();
    EXPECT_EQ(top->RD, 0xFFFF8001);
}

TEST_F(DataMemTestbench, WriteEnableTest)
{
    // sw 0x12345678 to 0x500
    top->A = 0x500;
    top->WD = 0x12345678;
    top->WE = 1;
    top->funct3 = 0b010;
    runSimulation(1);

    // same address and new data, but WE = 0: nothing should be written
    top->WD = 0xFFFFFFFF;
    top->WE = 0;
    runSimulation(1);

    top->eval();
    EXPECT_EQ(top->RD, 0x12345678);
}

TEST_F(DataMemTestbench, DataHexTest)
{
    // main() wrote de ad be ef into data.hex, loaded at 0x10000
    top->A = 0x10000;
    top->funct3 = 0b010;
    top->eval();

    EXPECT_EQ(top->RD, 0xEFBEADDE);
}

int main(int argc, char **argv)
{
    // data memory loads data.hex when it is created, so write it first
    FILE *f = fopen("data.hex", "w");
    fputs("de\nad\nbe\nef\n", f);
    fclose(f);

    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    remove("data.hex");

    return res;
}
