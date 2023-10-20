library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.ALL;

entity food is
  port (
    clk : in std_logic;
    reset : in std_logic;
    isEating : in boolean;
    snake : in snake_body;
    length : in integer range 1 to SNAKE_MAX:=1; 
    food_pos : out position;
    out_valid: out std_logic
  ) ;
end food ;

architecture Behavioral of food is

signal seed : unsigned (31 downto 0) := (others => '0');
signal my_food,next_food: position := FOOD_START_POS;
signal my_valid : std_logic := '1';
signal prev_Eating : boolean := false;
begin
    -- Output is combinational
    
    food_pos <= my_food;
    out_valid <= my_valid;
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                    my_valid <= '1';
                    seed <= (others => '0');
                    my_food <= FOOD_START_POS;
                    next_food<= FOOD_START_POS;
            else
                prev_Eating <= isEating;
                seed <= seed + 2 ; -- increment seed
                if ((not prev_Eating and isEating) or my_valid = '0') then -- generate new food
                    my_food <=next_food;
                    next_food <= createRandPosition(seed);
                    my_valid <= '1';
                    if (next_food.x = 0 or next_food.y = 0 or next_food.x >= GRID_WIDTH-1 or next_food.y >= GRID_HEIGHT-1) then 
                        my_valid <= '0'; -- food in wall, invalid output
                    else
                        for i in 0 to SNAKE_MAX-1 loop
                            if (i < length) then
                                if (snake(i) = next_food) then my_valid <= '0'; end if; -- food in snake, invalid output                                
                            end if;
                        end loop;
                    end if;
                else 
                    my_valid <= '1';
                end if;
            end if;
        end if;
        
    end process ; -- RNG

end architecture ; -- Behavioral