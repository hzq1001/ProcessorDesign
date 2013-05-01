LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY control IS
	PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
			-- TODO: Determine outputs --
			mem_reg, pc_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			aluop : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_src, reg_write, mem_write : OUT STD_LOGIC  
		 );	
END control;

ARCHITECTURE Behavior OF control IS
BEGIN
	-- TODO: implement behavior of control unit
	-- NOTE: Behavioral WHEN... ELSE statements may be used
	alu_src <= '0' WHEN op(4 DOWNTO 2) = "000"   ELSE       -- add,sub,and,or
	           '0' WHEN op(4 DOWNTO 1) = "0010"  ELSE       -- sll,srl
	           '0' WHEN op(4 DOWNTO 0) = "01001" ELSE       -- beq
	           '0' WHEN op(4 DOWNTO 0) = "01010" ELSE       -- bgt
	           '1';
	
	reg_write <= '1' WHEN op(4 DOWNTO 3) = "00"    ELSE     -- R type, addi, lw
	             '1' WHEN op(4 DOWNTO 0) = "01101" ELSE     -- jal	
	             '1' WHEN op(4 DOWNTO 0) = "01110" ELSE     -- input
	             '0';
	
	mem_write <= '1' WHEN op(4 DOWNTO 0) = "01000"  ELSE    -- sw
	             '0';
	
	mem_reg   <= "01" WHEN op(4 DOWNTO 0) = "00111" ELSE    -- lw
	             "10" WHEN op(4 DOWNTO 0) = "01101" ELSE    -- jal
	             "11" WHEN op(4 DOWNTO 0) = "01110" ELSE    -- input
	             "00";
	
	pc_src    <= "01" WHEN op(4 DOWNTO 0) = "01001" ELSE    -- beq
	             "01" WHEN op(4 DOWNTO 0) = "01010" ELSE    -- bgt
	             "10" WHEN op(4 DOWNTO 0) = "01011" ELSE    -- jr
	             "11" WHEN op(4 DOWNTO 0) = "01100" ELSE    -- j
	             "11" WHEN op(4 DOWNTO 0) = "01101" ELSE    -- jal
	             "00";
	             
	aluop     <= "001" WHEN op(4 DOWNTO 0) = "00001" ELSE   -- sub
	             "001" WHEN op(4 DOWNTO 0) = "01001" ELSE   -- beq
	             "001" WHEN op(4 DOWNTO 0) = "01010" ELSE   -- bgt
	             "010" WHEN op(4 DOWNTO 0) = "00010" ELSE   -- and
	             "011" WHEN op(4 DOWNTO 0) = "00011" ELSE   -- or
	             "100" WHEN op(4 DOWNTO 0) = "00100" ELSE   -- sll
	             "101" WHEN op(4 DOWNTO 0) = "00101" ELSE   -- srl
	             "000";
	            
	
END Behavior;