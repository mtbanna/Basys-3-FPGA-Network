library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.uart_constants.ALL;


entity uart_rx is
  Port (
    clk,uart_clk,rst : in std_logic;
    rx_in : in std_logic;
    data : out std_logic_vector(6 downto 0);
    data_new : out std_logic    
    );
end uart_rx;

architecture Behavioral of uart_rx is 


signal is_idle : boolean := true;
signal bit_count : integer range 0 to FRAME_LENGTH-1;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                is_idle <= true;
                bit_count <= 0;
                data_new <= '0';
            elsif(uart_clk='1') then
                if(is_idle) then
                    if(rx_in='0') then
                        is_idle <= false;
                        bit_count <= FRAME_LENGTH - 1 ;
                        data_new <= '0';
                    else
                        is_idle<=true;
                        bit_count <= 0;
                        data_new <= '0';
                    end if;
                else
                    data(bit_count)<=rx_in;
                    bit_count<=bit_count-1;
                    if(bit_count = 0) then
                        data_new <= '1';
                        is_idle <= true;
                    end if;
                end if;
            end if;
        end if;       
    end process;
end Behavioral;
