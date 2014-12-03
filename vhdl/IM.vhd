library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Driven by rising edge of clk50
-- One Read costs two cycles.
-- Function : Read Instruction from Sram

entity IM is
  
  port (
    clk50     : in    std_logic;
    PC        : in    std_logic_vector(15 downto 0);
    Ram2Addr  : out   std_logic_vector(17 downto 0);
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2OE    : out   std_logic;
    Ram2RW    : out   std_logic;
    Ram2EN    : out   std_logic;
    instruc   : out   std_logic_vector(15 downto 0)
    );

end IM;

architecture IM_Arch of IM is

  signal state : std_logic := '0';
  signal currInstr : std_logic_vector(15 downto 0) := X"0800";
  signal LowPC : std_logic_vector(3 downto 0) := "0000";
  
begin  -- IM_Arch

  Ram2EN <= '0';
  Ram2OE <= '0';
  Ram2RW <= '1';

  LowPC <= PC(3 downto 0);
  
  currInstr <= "01101" & "001" & "00101010" when LowPC = "0000" else
               -- LI R1 0x2A.  R1 = 0x2A

               "01101" & "010" & "00000100" when LowPC = "0001" else
               -- LI R2 0x4   R2 = 0x4

               "11101" & "010" & "00000000" when LowPC = "0010" else
               -- JR R2
               
               "11100" & "001" & "010" & "011" & "01" when LowPC = "0011" else
               -- ADDU R1 R2 R3.  R3 = R1 + R2 = 0x43

               "01101" & "011" & "10011001" when LowPC = "0100" else
               -- LI R3 0x99   R3 = 0x99
               
               X"0800";

  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      case state is
        when '0' =>
          Ram2Data <= (others => 'Z');
          Ram2Addr <= "00" & PC;
          state <= '1';
        when '1' =>
--          instruc <= Ram2Data;
          instruc <= currInstr;
          state <= '0';
        when others => null;
      end case;
    end if;
  end process;
  
  --clk_addr <= CPU_CLK after 20 ns;
  --clk_out <= CPU_CLK after 20 ns;

  --process (CPU_CLK)
  --begin  -- process
  --  if rising_edge(CPU_CLK) then
  --    Ram2Data <= (others => 'Z');
  --  end if;
  --end process;

  --process (clk_addr)
  --begin  -- process
  --  if rising_edge(clk_addr) then
  --    Ram2Addr <= "00" & PC;
  --  end if;
  --end process;

  --process (clk_out)
  --begin  -- process
  --  if rising_edge(clk_out) then
  --    instruc <= Ram2Data;
  --  end if;
  --end process;
  
end IM_Arch;
