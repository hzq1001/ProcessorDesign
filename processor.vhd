-- Course: Duke University, ECE 590 (Fall 2012)
-- Description: unpipelined processor
-- Revised: October 6, 2012

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
library altera;
use altera.altera_primitives_components.all;

ENTITY processor IS
    PORT (	clock, reset	: IN STD_LOGIC;
			keyboard_in	: IN STD_LOGIC_VECTOR(31 downto 0);
			keyboard_ack, lcd_write	: OUT STD_LOGIC;
			lcd_data	: OUT STD_LOGIC_VECTOR(31 downto 0);
			
			---test output-----
			--test_imem_q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			--test_imem_in :OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			--test_op : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			--test_regw : OUT STD_LOGIC ;
			--test_imem_dst : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			--test_data_w_reg : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_read_reg_A : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_read_reg_B : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_isEqual : OUT STD_LOGIC;
            --test_alu_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_alu_in_a : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_alu_in_b : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_dmem_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_dmem_address  : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
            --test_pc_branch : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
            --test_dmem_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            --test_isGreater : OUT STD_LOGIC);

END processor;

ARCHITECTURE Structure OF processor IS
	SIGNAL imem_out:  STD_LOGIC_VECTOR (31 DOWNTO 0) ;
	SIGNAL data_w_reg,data_reg_a,data_reg_b:  STD_LOGIC_VECTOR (31 DOWNTO 0) ;
	SIGNAL alu_in_a, alu_in_b,alu_out:  STD_LOGIC_VECTOR (31 DOWNTO 0) ;
	SIGNAL dmem_in,dmem_out:  STD_LOGIC_VECTOR (31 DOWNTO 0) ;
	SIGNAL alu_equal, alu_greater,reg_w,mem_w,alu_src_ctl : STD_LOGIC ;
	SIGNAL alu_op : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL mem_to_reg, pc_ctl : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL dffe_in,dffe_out, pc_out,pc_branch,d_address,dffe_reset : STD_LOGIC_VECTOR  (11 DOWNTO 0);
	SIGNAL imem_rd,imem_rs,imem_rt : STD_LOGIC_VECTOR (4 DOWNTO 0);
	 
	 
	 
	 
	COMPONENT imem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clken	: IN STD_LOGIC ;
				clock	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT dmem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clock	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				wren	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT regfile IS
		PORT (	clock, ctrl_writeEnable, ctrl_reset	: IN STD_LOGIC;
				ctrl_writeReg, ctrl_readRegA, ctrl_readRegB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				data_writeReg	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				data_readRegA, data_readRegB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	
	END COMPONENT;


	
	COMPONENT alu IS
		PORT (	data_operandA, data_operandB	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit inputs
				ctrl_ALUopcode	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	-- 3bit ALU opcode
				data_result	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit output
				isEqual, isGreaterThan	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT control IS
		PORT ( -- Implement this --
              op : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
              mem_reg, pc_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
              aluop : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
              alu_src, reg_write, mem_write : OUT STD_LOGIC  
              );	
	END COMPONENT;
	COMPONENT Pc IS 
    GENERIC (hi : natural);
        PORT(
             in1, in2: in std_logic_vector (hi downto 0);  
             sum : out std_logic_vector (hi downto 0)
            );
    END COMPONENT;

 
	
BEGIN
	-- TODO: build processor --
	my_imem : imem PORT MAP (
	                         address => dffe_reset, 
	                         clken => '1',
	                         clock => clock,
	                         q => imem_out);
	
	my_regfile : regfile PORT MAP (
	                               clock => clock, 
	                               ctrl_writeEnable => reg_w, 
	                               ctrl_reset => reset, 
	                               ctrl_writeReg => imem_rd, 
	                               ctrl_readRegA => imem_rs, 
	                               ctrl_readRegB => imem_rt, 
	                               data_writeReg => data_w_reg, 
	                               data_readRegA => data_reg_a,
	                               data_readRegB => data_reg_b);
	
	my_alu: alu PORT MAP (
	                      data_operandA  => alu_in_a, 
	                      data_operandB  => alu_in_b,
	                      ctrl_ALUopcode => alu_op, 
	                      data_result    => alu_out, 
	                      isEqual        => alu_equal, 
	                      isGreaterThan  => alu_greater); 
	
	my_dmem: dmem PORT MAP (
	                        address => d_address, 
	                        clock  =>  not clock, 
	                        data   => dmem_in, 
	                        wren   => mem_w, 
	                        q      => dmem_out);
	
	my_control: control PORT MAP(
	                            op => imem_out(31 DOWNTO 27), 
	                            mem_reg   => mem_to_reg, 
	                            pc_src    => pc_ctl, 
	                            aluop     => alu_op,
	                            alu_src   => alu_src_ctl,
	                            reg_write => reg_w,
	                            mem_write => mem_w);
	                    

	
	my_Pc: Pc GENERIC MAP (hi=>11)  
                          PORT MAP(
                                   in1 => dffe_out,
                                   in2 => "000000000001",
                                   sum => pc_out);
                 
    G1: FOR i in 11 DOWNTO 0 GENERATE
    my_DFFE : DFFE PORT MAP(
                            d=> dffe_in(i),--pc_out(i), 
                            clk=> clock, 
                            clrn=> not reset,
                            prn=>'1',
                            ena=>'1', 
                            q=> dffe_out(i));
    END GENERATE G1;
    
    branch_pc : Pc GENERIC MAP (hi=>11)
                      PORT MAP(
	                           in1 => pc_out,
	                           in2 => imem_out(11 DOWNTO 0),
	                           sum => pc_branch);

    
  
    ---PC source select---
    
    dffe_in <= pc_branch WHEN pc_ctl = "01" AND alu_equal = '1' AND imem_out(31 DOWNTO 27) = "01001" ELSE    --beq   
               pc_branch WHEN pc_ctl = "01" AND alu_greater = '1' AND imem_out(31 DOWNTO 27) = "01010" ELSE  --bgt
               data_reg_a (11 DOWNTO 0) WHEN pc_ctl = "10" ELSE                                              -- jr
               imem_out(11 DOWNTO 0) WHEN pc_ctl = "11" ELSE                                                 -- j and jal
               pc_out;
	
	dmem_in <= data_reg_b WHEN mem_w = '1' ELSE                                                              -- sw
			   "00000000000000000000000000000000";
    
    d_address <= alu_out (11 DOWNTO 0) WHEN imem_out(31 DOWNTO 27) = "00111" ELSE      --lw
                 alu_out (11 DOWNTO 0) WHEN imem_out(31 DOWNTO 27) = "01000" ELSE      --sw
                 "000000000000";
			   
	imem_rd <= "11111" WHEN imem_out (31 DOWNTO 27) = "01101" ELSE -- jal
	           imem_out (26 DOWNTO 22);
	
	imem_rs <= imem_out (26 DOWNTO 22) WHEN imem_out (31 DOWNTO 27) = "01011" ELSE   -- JR
	           imem_out (26 DOWNTO 22) WHEN imem_out (31 DOWNTO 27) = "01111" ELSE   -- OUTPUT
	           imem_out (21 DOWNTO 17);
	           
	imem_rt <= imem_out (26 DOWNTO 22) WHEN imem_out (31 DOWNTO 27) = "01000" ELSE   -- SW
	           imem_out (26 DOWNTO 22) WHEN imem_out (31 DOWNTO 27) = "01001" ELSE   -- BEQ
	           imem_out (26 DOWNTO 22) WHEN imem_out (31 DOWNTO 27) = "01010" ELSE   -- BGT
	           imem_out (16 DOWNTO 12);
	           
	
	
	---ALU data_operandB select---
	alu_in_b <= data_reg_b when alu_src_ctl = '0' ELSE   --- R type 
	            SXT(imem_out(16 DOWNTO 0), 32);          --- I type 
	            
	alu_in_a <= data_reg_a;

	            
    ---Reg write data select ----
    data_w_reg <= dmem_out    when mem_to_reg = "01" ELSE       -- lw
                  EXT(pc_out,32) when mem_to_reg = "10" ELSE    -- jal
                  keyboard_in when mem_to_reg = "11" ELSE		-- input
                  alu_out;                                      -- R type + addi
    
    
   
              
    --- implement of input----
    keyboard_ack <= '1' when imem_out(31 DOWNTO 27) = "01110" ELSE
                    '0';
    
    --- implement of output ---
    lcd_write <= '1' when imem_out(31 DOWNTO 27) = "01111" ELSE
                 '0';
    
        
    lcd_data <= "000000000000000000000000" & data_reg_a (7 DOWNTO 0) WHEN imem_out(31 DOWNTO 27) = "01111" ELSE   -- LCD output = $rd (low 8bits)
                "00000000000000000000000000000000" ;
    
    
    
    G2: FOR i in 11 DOWNTO 0 GENERATE
	dffe_reset(i) <= dffe_in(i) AND (NOT reset);     -- reset dffe
	END GENERATE G2;
	
  
    ----test output -----
    --test_imem_q <= imem_out;
    --test_imem_in <= dffe_reset;
    --test_op <= imem_out(31 DOWNTO 27);
    --test_regw <= reg_w;
	--test_imem_dst <= imem_rd;
	--test_data_w_reg <= data_w_reg ;
	--test_read_reg_A <= data_reg_a ;
    --test_read_reg_B <= data_reg_b ;
    --test_isEqual <= alu_equal;
    --test_alu_out <= alu_out;
    --test_alu_in_a <= alu_in_a;
    --test_alu_in_b <= alu_in_b;
    --test_dmem_out <= dmem_out;
    --test_dmem_address <= d_address;
    --test_dmem_data <= dmem_in;
    --test_isGreater <= alu_greater;
    --test_pc_branch <= pc_branch;
        
    	
	 
END Structure;