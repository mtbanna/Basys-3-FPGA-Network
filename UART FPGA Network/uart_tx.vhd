library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.uart_constants.ALL;


entity uart_tx is
  Port (
    clk,uart_clk,rst : in std_logic;
    data : in std_logic_vector(6 downto 0);
    data_new : in std_logic;
    tx_out : out std_logic 
    );
end uart_tx;

architecture Behavioral of uart_tx is 


signal is_idle : boolean := true;
signal bit_count : integer range 0 to FRAME_LENGTH-1;
signal prev_data_new : std_logic;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                is_idle <= true;
                tx_out <= '1';
                bit_count <= 0;
            elsif(uart_clk='1') then
                if(prev_data_new='0' and data_new='1') then
                    is_idle <= false;
                    tx_out <= '0';
                    bit_count<=FRAME_LENGTH-1;
                else
                    if(is_idle) then
                        tx_out <= '1';
                        bit_count <= 0;
                    else
                        tx_out <= data(bit_count);
                        bit_count <= bit_count-1;
                        if(bit_count = 0) then
                            is_idle <= true;
                        end if;
                    end if;   
                end if;
                prev_data_new <= data_new;
            end if;
        end if;       
    end process;
end Behavioral;
