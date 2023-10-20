library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package constants is

    constant H_RES : integer := 640;     -- horizontal resolution
    constant V_RES : integer := 480;     -- vertical resolution
    constant H_SYNC_PULSE : integer := 96;   -- horizontal sync pulse width
    constant H_FRONT_PORCH : integer := 16;  -- horizontal front porch
    constant H_BACK_PORCH : integer := 48;   -- horizontal back porch
    constant V_SYNC_PULSE : integer := 2;    -- vertical sync pulse width
    constant V_FRONT_PORCH : integer := 10;  -- vertical front porch
    constant V_BACK_PORCH : integer := 33;   -- vertical back porch
    constant V_START : integer := V_SYNC_PULSE+V_BACK_PORCH-1;
    constant H_START : integer := H_SYNC_PULSE+H_BACK_PORCH-1;

    
    constant H_CHARS : integer := 640/8;
    constant V_CHARS : integer := 480/16;
    
    constant CHAR_WIDTH : integer := 8;
    constant CHAR_HEIGHT : integer := 16;
    
    subtype color is std_logic_vector(11 downto 0);

    type t_chars is array (0 to H_CHARS-1,0 to V_CHARS-1) of std_logic_vector(6 downto 0);


    constant BLACK : color := ( "000000000000"); 
    constant WHITE : color := ( "111111111111");
    constant RED : color := ( "111100000000");
    constant BLUE : color := ( "000000001111");
    constant GREEN : color := ( "000011110000");
    constant DARKBLUE : color := ( "000000001000");
    constant CHAR_CLR : color := WHITE;
    constant BKG_CLR : color := DARKBLUE;

    
    
end constants;


package body constants is

end package body constants;
