

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
 
    
entity Display is
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;                           --reset
        chars : in t_chars ; 
        countchx : in integer range 0 to H_CHARS-1;
        countchy : in integer range 0 to V_CHARS-1;                           
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
    );
end Display;

   
architecture Behavioral of Display is

component font_rom is
    port(
  clk: in std_logic;
  addr: in std_logic_vector(10 downto 0);
  data: out std_logic_vector(7 downto 0)
    );
end component;
signal vga_clk,cnt_vga : STD_LOGIC; 
signal h_count : integer range 0 to H_RES + H_SYNC_PULSE + H_FRONT_PORCH + H_BACK_PORCH; -- counter to iterate through VGA pixels in row
signal v_count : integer range 0 to V_RES + V_SYNC_PULSE + V_FRONT_PORCH + V_BACK_PORCH; -- counter to iterate through VGA lines
signal disp_signal : STD_LOGIC :='0'; -- flag to display image
signal rgb : color := BLACK;
signal addr: std_logic_vector(10 downto 0);
signal data: std_logic_vector(7 downto 0);
signal font_idx : std_logic_vector(3 downto 0) := (others => '0');
begin 
    --INSTANTIATING
font_rom_0:font_rom port map(clk=>vga_clk,addr=>addr,data=>data);

    -- COMBINATIONAL
    r <= rgb(11 downto 8);
    g <= rgb(7 downto 4);
    b <= rgb(3 downto 0);

   -- SEQUENTIAL
    process(vga_clk)
    begin
        addr(3 downto 0) <= std_logic_vector(to_unsigned(((v_count-V_START) mod CHAR_HEIGHT),4));
        addr(10 downto 4) <= chars((h_count-H_START)/CHAR_WIDTH,(v_count-V_START)/CHAR_HEIGHT);
    end process;
    
    
    
    process (vga_clk) -- horizontal sync generation
    begin
        
        if rising_edge(vga_clk) then
            if reset = '1' then
                        h_count<=0;
                        h_sync <= '1';
                        rgb <= BLACK;
            elsif h_count >= H_START + H_RES + H_FRONT_PORCH then --hsync pulse start
                h_count <= 0;
                h_sync <= '0';  -- sync
            elsif h_count >= H_START + H_RES  then -- front porch
                h_sync <= '1';   
                rgb <= BLACK;
                h_count <= h_count + 1;
            elsif h_count >= H_START then -- active display time
                h_sync <= '1';  --  sync
                if disp_signal = '1' then
                    if( (v_count-V_START)/CHAR_HEIGHT<countchy or((v_count-V_START)/CHAR_HEIGHT=countchy and (h_count-H_START)/CHAR_WIDTH<countchx) ) then                        
                        if(data(7-((h_count-H_START) mod CHAR_WIDTH))='1')then
                            rgb<=CHAR_CLR;
                        else
                            rgb<=BKG_CLR;
                        end if;  
                    else
                        rgb <= BKG_CLR; --bkg
                    end if;
                else
                    rgb <= BLACK;
                    
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
    process(clk) --clock division from 100 MHz to 25 MHz
    begin
        if reset = '1' then
            cnt_vga <= '0';
            vga_clk <= '0';
        elsif rising_edge(clk) then
            if cnt_vga = '1' then
                vga_clk <= not vga_clk;
            end if;
            cnt_vga <=  not cnt_vga;
        end if;
    end process;
end Behavioral;
