library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.ALL;

entity snake is
    port (
        clk : in STD_LOGIC;
        reset,w,a,s,d : in STD_LOGIC;            --wasd represent movement directions like in video games
        food : in position;
        bod : out snake_body;
        length : out integer range 1 to SNAKE_MAX;
        isEating : out boolean;
        isDead : out boolean
    );
end snake;

architecture Behavioral of snake is

    
    

    signal my_bod : snake_body :=  START_BODY;
    signal my_length : integer range 1 to SNAKE_MAX:=1; 
    signal my_isEating : boolean := false;
    signal my_isDead : boolean := false;
    signal my_dir : direction_type := RIGHT;
    
begin
        
    -- Outputs
    bod <= my_bod; 
    length <= my_length;
    isEating <= my_isEating;
    isDead <= my_isDead;

    

    process(clk) -- snake moving
    begin
                    
        if (rising_edge(clk)) then
            if (reset = '1') then -- snake of length 1 moving to the right
                my_bod  <=  START_BODY;
                my_length  <= 1;
                my_isDead  <= false;
                my_dir <= RIGHT;
            elsif(not my_isDead)then
            -- Change direction
                if (w = '1' and a = '0' and s = '0' and d = '0' and my_dir /= DOWN) then my_dir <= UP; -- up
                elsif (w = '0' and a = '1' and s = '0' and d = '0' and my_dir /= RIGHT) then my_dir <= LEFT; -- left
                elsif (w = '0' and a = '0' and s = '1' and d = '0' and my_dir /= UP) then my_dir <= DOWN; -- down
                elsif (w = '0' and a = '0' and s = '0' and d = '1' and my_dir /= LEFT) then my_dir <= RIGHT; -- right
                else my_dir <= my_dir;
                end if;
            
                -- Move
                case my_dir is
                    when UP => my_bod(0).y <= my_bod(0).y - 1;
                    when LEFT => my_bod(0).x <= my_bod(0).x - 1;
                    when DOWN => my_bod(0).y <= my_bod(0).y + 1;
                    when RIGHT => my_bod(0).x <= my_bod(0).x + 1;
                    --when others => null;
                end case;

                for i in 1 to SNAKE_MAX-1 loop
                    if (i < my_length and my_length > 1) then                        
                        my_bod(i) <= my_bod(i-1);                        
                        if (my_bod(0) = my_bod(i)) then my_isDead <= true; end if; -- check if snake is dead
                    end if;
                end loop;
                my_bod(my_length) <= my_bod(my_length-1); 
                if(food = my_bod(0)) then -- head is eating when it coincides with food
                    my_isEating <= true;  
                    my_length <= my_length + 1;  
                else
                    my_isEating <= false;   
                end if;
            
            -- Check if snake is dead
                if (my_bod(0).x = 0 or my_bod(0).y = 0 or my_bod(0).x = GRID_WIDTH-1 or my_bod(0).y = GRID_HEIGHT-1) then
                    my_isDead <= true;
                end if;
            end if;
        end if;
    end process;

end Behavioral;