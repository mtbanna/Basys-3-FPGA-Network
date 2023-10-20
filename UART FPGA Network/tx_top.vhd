----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2023 01:10:57 PM
-- Design Name: 
-- Module Name: tx_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.uart_constants.ALL;


entity tx_top is
    Port ( clk,rst,ps2_clk,ps2_data : in STD_LOGIC;
           tx_out : out STD_LOGIC);
end tx_top;

architecture Behavioral of tx_top is
COMPONENT ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      rst : in std_logic;
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
END COMPONENT;

component uart_tx is 
    Port (
    clk,uart_clk : in std_logic;
    rst : in std_logic;
    data : in std_logic_vector(6 downto 0);
    data_new : in std_logic;
    tx_out : out std_logic 
    );
end component;
signal ascii_new,prev_ascii_new,data_new,prev_data_new : std_logic;
signal ascii_code,data : std_logic_vector(6 downto 0);
signal count : integer range 0 to BIT_TIME-1;
signal uart_clk : std_logic; -- 1 when count is 0 and 0 otherwise
begin
    ps2_keyboard_to_ascii_0: ps2_keyboard_to_ascii port map(clk=>clk,rst=>rst,ps2_clk=>ps2_clk,ps2_data=>ps2_data,ascii_new=>ascii_new,ascii_code=>ascii_code);
    uart_tx_0: uart_tx port map(clk=>clk,uart_clk=>uart_clk,rst=>rst,data=>data,data_new=>data_new,tx_out=>tx_out);
    
    
    process(clk) 
    begin
        if(uart_clk = '1') then
            if(prev_ascii_new ='0' and ascii_new='1') then
                data_new <= '1';
                data <= ascii_code;
            end if;
        end if;
    end process;
    
    
    
    process(clk)    -- handling count and uart clk
    begin
        if(rising_edge(clk)) then
            if(count = 0) then
                count <= BIT_TIME - 1;
                uart_clk <= '1';
            else 
                count <= count-1;
                uart_clk <= '0';
            end if;
        end if;
    end process;
end Behavioral;
