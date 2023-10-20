library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package uart_constants is

    constant BAUD_RATE : integer := 9600;
    constant CLK_FREQ : integer := 100_000_000;
    constant BIT_TIME : integer := CLK_FREQ/BAUD_RATE;
    constant FRAME_LENGTH : integer := 7;

    
    
end uart_constants;


package body uart_constants is

end package body uart_constants;

