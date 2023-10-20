-- 
-- screen:
-- __________________________________________________
--|                     Title                        |
--|                 Score maybe                      |                  
--|         ________________________________         |                              
--|<------>|                                |        |
--| grid   |     HERE IS GRID               |        |
--| origin |                                |        | 
--|        |                                |        |
--|        |                                |        |
--|        |                                |        |
--|        |________________________________|        |
--|         <------------------------------>         |
--|                 grid size                        |
--|__________________________________________________|


library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
 
    
entity Display is
    port (
        vga_clk : in STD_LOGIC;  --clocks
        reset : in STD_LOGIC;                           --reset
        mygrid : in grid;                               --current grid colors
        vcount : out integer range 0 to V_RES + V_SYNC_PULSE + V_FRONT_PORCH + V_BACK_PORCH;
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
    );
end Display;

   
architecture Behavioral of Display is
    
    signal h_count : integer range 0 to H_RES + H_SYNC_PULSE + H_FRONT_PORCH + H_BACK_PORCH; -- counter to iterate through VGA pixels in row
    signal v_count : integer range 0 to V_RES + V_SYNC_PULSE + V_FRONT_PORCH + V_BACK_PORCH; -- counter to iterate through VGA lines
    signal disp_signal : STD_LOGIC :='0'; -- flag to display image
    signal rgb : color := BLACK;
    
begin 
    -- COMBINATIONAL
    
    r <= rgb(11 downto 8);
    g <= rgb(7 downto 4);
    b <= rgb(3 downto 0);
    
    vcount<= v_count;
    -- SEQUENTIAL

    process (vga_clk) -- horizontal sync generation
    begin
        
        if rising_edge(vga_clk) then
            if reset = '1' then
                        h_count<=0;
                        h_sync <= '1';
                        rgb <= BLACK;
            elsif h_count >= H_START + H_RES + H_FRONT_PORCH then -- hsync pulse start
                h_count <= 0;
                h_sync <= '0';  -- sync
            elsif h_count >= H_START + H_RES  then -- front porch
                h_sync <= '1';   
                rgb <= BLACK;
                h_count <= h_count + 1;
            elsif h_count >= H_START then -- active display time
                h_sync <= '1';  --  sync
                if disp_signal = '1' then
                    if(h_count>=GRID_ORIGIN_X and h_count<GRID_END_X and v_count>=GRID_ORIGIN_Y and v_count<GRID_END_Y) then                        
                            rgb <= mygrid((h_count-GRID_ORIGIN_X)/CELL_SIZE,(v_count-GRID_ORIGIN_Y)/CELL_SIZE);
                    else
                        rgb <= BKG_COLOR;
                    end if;
                end if;
                h_count <= h_count + 1;
            elsif h_count >= H_SYNC_PULSE - 1 then  -- back porch
                h_sync <= '1';  
                rgb <= BLACK;
                h_count <= h_count + 1;
            else -- hsync pulse
                h_sync <= '0';   
                rgb <= BLACK;
                h_count <= h_count + 1;
            end if;
        end if;
    end process;
 
    process (vga_clk) -- vertical sync generation
    begin
        if rising_edge(vga_clk) then
            if reset = '1' then
                v_count<=0;
                v_sync <= '1';
                disp_signal <= '0';
            elsif h_count >= H_START + H_RES + H_FRONT_PORCH then -- end of horizontal cycle
                if v_count >= V_START + V_RES + V_FRONT_PORCH  then -- vsync pulse time
                    v_sync <= '0';
                    v_count <= 0;
                    disp_signal <= '0';
                elsif v_count >= V_START + V_RES then --front porch
                    v_sync <= '1';
                    disp_signal <= '0';
                    v_count <= v_count + 1;
                elsif v_count >= V_START then -- active display time
                    v_sync <= '1';
                    v_count <= v_count + 1;
                    disp_signal <= '1';
                elsif v_count >= V_SYNC_PULSE  - 1 then --back porch
                    v_sync <= '1';
                    disp_signal <= '0';
                    v_count <= v_count + 1;
                else -- v_sync pulse
                    v_sync <= '0';
                    disp_signal <= '0';
                    v_count <= v_count + 1;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
