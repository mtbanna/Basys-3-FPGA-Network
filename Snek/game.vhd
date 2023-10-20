library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
 
    
entity game is
    port (
        clk : in STD_LOGIC;                             --clock (100MHz)
        reset : in STD_LOGIC;                           --reset
        w,a,s,d : in STD_LOGIC;                         --wasd
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color    
    );
end game;

   
architecture Behavioral of game is

    
    
    signal vga_clk,frame_clk,game_clk : std_logic := '0';
    signal v_count : integer range 0 to V_RES + V_SYNC_PULSE + V_FRONT_PORCH + V_BACK_PORCH; -- counter to iterate through VGA lines
    signal mygrid : grid := INIT_GRID; 
    signal isEating,isDead : boolean := false;
    signal length : integer range 1 to SNAKE_MAX:=1; 
    signal food_pos : position := FOOD_START_POS;
    signal snake : snake_body := (others => START_POS);
    signal food_valid : std_logic := '1';
    signal prev_tail : position := START_POS;
    
begin 

Uclks: entity work.Clocks(Behavioral) port map(clk=>clk,reset =>reset,v_count=>v_count,vga_clk => vga_clk,frame_clk => frame_clk,game_clk=>game_clk);
Udisp: entity work.Display(Behavioral) port map (vga_clk => vga_clk, reset => reset, mygrid => mygrid,vcount=>v_count,h_sync => h_sync, v_sync => v_sync, r=>r, g=>g, b=>b);
Usnek: entity work.snake(Behavioral) port map(clk=>game_clk,reset=>reset,w=>w,a=>a,s=>s,d=>d,food=>food_pos,bod=>snake,length =>length,isEating=> isEating,isDead =>isDead);
Ufood: entity work.food(Behavioral) port map(clk => vga_clk,reset => reset,isEating=> isEating,snake=>snake,length=>length,food_pos=>food_pos,out_valid=>food_valid);

    process (vga_clk)
    variable i : integer range 0 to GRID_WIDTH-1 := 0;
    variable j : integer range 0 to GRID_HEIGHT-1 := 0;
    variable k : integer range 0 to SNAKE_MAX+1 :=0;                        
    begin
        if(rising_edge(vga_clk)) then
            if(v_count = 0 or v_count = V_START + V_RES) then
                i :=0; j:=0; k:=0;
            elsif(v_count< V_START) then
                if(k=0)then
                    mygrid(snake(0).x,snake(0).y) <= HEAD_COLOR;
                elsif(k < length) then
                    mygrid(snake(k).x,snake(k).y) <= SNEK_COLOR;
                elsif(k = length) then
                    if(food_valid='1' and (food_pos /= snake(0))) then
                        mygrid(food_pos.x,food_pos.y) <= FOOD_COLOR;
                    end if;
                end if;
                if(k <= SNAKE_MAX) then
                    k:= k+1;
                end if;                
            elsif(v_count > V_START + V_RES ) then
                if(i=0 or i=GRID_WIDTH-1 or j=0 or j=GRID_HEIGHT-1) then
                    mygrid(i,j) <= WALL_COLOR; 
                elsif((i+j)mod 2 = 0)then 
                    mygrid(i,j) <= GRID_COLOR1; 
                else 
                    mygrid(i,j) <= GRID_COLOR2; 
                end if;
                if(j >= GRID_HEIGHT-1 and i >= GRID_WIDTH-1) then
                    j := 0; i:=0;
                elsif(i >= GRID_WIDTH-1) then
                    j := j+1; i := 0;
                else
                    i:= i+1;
                end if;    
            end if;
        end if;
    end process;
            



end Behavioral;