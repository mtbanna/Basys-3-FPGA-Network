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
    
    constant GRID_WIDTH : integer := 25;     -- grid width in number of cells
    constant GRID_HEIGHT : integer := 15;    -- grid height in number of cells
    constant CELL_SIZE : integer := 20;      -- size of one grid cell in pixels
    
    constant GRID_SIZE_X : integer := GRID_WIDTH*CELL_SIZE;     -- grid width in pixels (has to be < H_RES)
    constant GRID_SIZE_Y : integer := GRID_HEIGHT*CELL_SIZE;    -- grid height in pixels (has to be < V_RES)
    constant GRID_ORIGIN_X : integer := H_START + ((H_RES-GRID_SIZE_X)/2);
    constant GRID_ORIGIN_Y : integer := V_START + ((V_RES-GRID_SIZE_Y)*3/4);
    constant GRID_END_X : integer := GRID_ORIGIN_X+GRID_SIZE_X;
    constant GRID_END_Y : integer := GRID_ORIGIN_Y+GRID_SIZE_Y;
            
    constant SNAKE_MAX : integer :=  16; --(GRID_WIDTH-2)*(GRID_HEIGHT-2);
    

    subtype color is std_logic_vector(11 downto 0);

    

    type grid is array (0 to GRID_WIDTH-1,0 to GRID_HEIGHT-1) of color;

    constant BLACK : color := ( "000000000000"); 
    constant WHITE : color := ( "111111111111");
    constant RED : color := ( "111100000000");
    constant BLUE : color := ( "000000001111");
    constant GREEN : color := ( "000011110000");
    constant BKG_COLOR : color := ( "010101011110");
    constant SNEK_COLOR : color := ( "000101100010");
    constant HEAD_COLOR : color := ( "000101010010");
    constant WALL_COLOR : color := ( "111110100000");
    constant FOOD_COLOR : color := ( "111000010001");
    constant GRID_COLOR1 : color := ( "110111011101");
    constant GRID_COLOR2 : color := WHITE;

    type direction_type is (UP, DOWN, LEFT, RIGHT);
    type position is record
            x : integer range 0 to GRID_WIDTH - 1;
            y : integer range 0 to GRID_HEIGHT - 1;
        end record;
    type snake_body is array (0 to SNAKE_MAX-1) of position; -- array of positions of snake body
    
    
    constant START_POS : position := (x => GRID_WIDTH/4, y => GRID_HEIGHT/2);
    constant FOOD_START_POS : position := (x => GRID_WIDTH*3/4, y => GRID_HEIGHT/2);
    constant START_BODY : snake_body := (others => START_POS);

    
    
    function INIT_GRID return grid;
    function createRandPosition (seed : unsigned (31 downto 0) := (others => '0')) return position;

end constants;


package body constants is

    function INIT_GRID return grid is
        variable fngrid : grid;
    begin
        for i in 0 to GRID_WIDTH-1 loop
            for j in 0 to GRID_HEIGHT-1 loop
                if(i=0 or i=GRID_WIDTH-1 or j=0 or j=GRID_HEIGHT-1) then
                    fngrid(i,j) := WALL_COLOR; 
                else
                    if((i+j)mod 2 = 0)then 
                        fngrid(i,j) := GRID_COLOR1; 
                    else 
                        fngrid(i,j) := GRID_COLOR2; 
                    end if;
                end if;
            end loop;
        end loop;
        return fngrid;
    end function;
    
    function createRandPosition (seed : unsigned (31 downto 0) := (others => '0')) return position is -- outputs a random position
        variable pos : position;
        variable temp : unsigned (31 downto 0);
    begin
        temp := rotate_right(seed, 11) xor rotate_left(seed+1,7) xor x"1D4AF943";
        pos.x := to_integer(temp(25 downto 10)) mod GRID_WIDTH;
        pos.y := to_integer(temp(17 downto 2)) mod GRID_HEIGHT;
        return pos;
    end function;

end package body constants;
