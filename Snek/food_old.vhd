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
    snake_pos : in snake_body;
    length : in integer;
    food_pos : out position;
    out_valid: out std_logic
  ) ;
end food ;

architecture Behavioral of food is

signal ready : std_logic := '0';
signal valid : std_logic := '0';
signal rng : std_logic_vector(31 downto 0) := (others => '0');
signal out_food : position := (x => 0, y => 0);
signal x : integer range 0 to GRID_WIDTH - 1 := 0;
signal y : integer range 0 to GRID_HEIGHT - 1 := 0;

function createPosition ( -- takes x and y and returns a position of (x,y)
    x : integer := 0;
    y : integer := 0) return position is
    variable pos : position;
begin
    pos.x := x;
    pos.y := y;
    return pos;
end function;

begin
    -- Output is combinational
    x <= to_integer(unsigned(rng(15 downto 0))) mod GRID_WIDTH;
    y <= to_integer(unsigned(rng(31 downto 16))) mod GRID_HEIGHT;
    out_food <= createPosition(x,y);
    food_pos <= out_food;

    inst_prng: entity work.rng_xoshiro128plusplus
        generic map (
            init_seed => x"0123456789abcdef3141592653589793" )
        port map (
            clk       => clk,
            rst       => reset,
            reseed    => '0',
            newseed   => (others => '0'),
            out_ready => ready,
            out_valid => valid,
            out_data  => rng );

    process(clk)
    begin
        if (rising_edge(clk)) then
            if (isEating) then -- generate new food next clk cycle
                ready <= '1';
            else
                ready <= '0';
            end if;

            if (valid = '1') then -- check if food position in snake or wall
                out_valid <= '1';
                ready <= '0';
                if (x = 0 or y = 0 or x = GRID_WIDTH-1 or y = GRID_HEIGHT-1) then -- food in wall
                    out_valid <= '0'; -- invalid output
                    ready <= '1'; -- generate new number
                else
                    for i in 0 to GRID_WIDTH*GRID_HEIGHT-1 loop
                        if (i <= length - 1) then
                            if (snake_pos(i) = out_food) then -- food in snake
                                out_valid <= '0'; 
                                ready <= '1';
                            end if;
                        end if;
                    end loop;
                end if;
            end if;

            if (reset = '1') then
                out_valid <= '0';
                ready <= '0';
                food_pos <= createPosition(0,0);
            end if;
        end if;
        
    end process ; -- RNG

end architecture ; -- Behavioral