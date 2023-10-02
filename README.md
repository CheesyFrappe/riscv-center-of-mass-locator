# RISC-V Center of Mass Indicator

The aim is to develop a program in Assembly RISC-V to locate characters in an image. 
Given a file with an image in RGB format, the program should generate a new image that identifies the character chosen by the user. 

<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/95532068-3e24-48ba-80bb-c1ac6e716bb4"/>
</div><br>
  
It is seen that each character has a different color tone in the image. Master Yoda has more shades
of green, Darth Maul is more red, and Boba Fett is closer to cyan. These characters can be distinguished by their color tones.

Each of them has a dominant color tone which is mentioned above. The best way to locate a character
is to find the center of mass of the character by the dominant pixels.


## Simulator
The project was developed in [rars](https://github.com/TheThirdOne/rars) simulator. To run the program be sure the simulator is installed correctly.<br>

## RGB
In this project, the image is an RGB formatted file with 8 bits of color depth. Which means every
pixel contains three bytes corresponding to the RGB values. The image can be represented as a matrix
where each value is a pixel with three components. However, image pixels are stored sequentially in a
file in raw major1 order:
<br>
<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/af7e4dae-134a-422f-a05f-1a2aa30c2aa9"/>
</div><br>

In order to convert the image into an RGB-formatted file, `ImageMagick` is used. With the use of the
proper commands images can be converted into different formats. 

### Installing `ImageMagick` in Linux 

```shell
sudo apt install imagemagick
```

Before turning into PNG or JPG from RGB, these parameters should be used:
```shell
-size 320x180 and -depth 8
```

Some examples of converting between JPEG, PNG and RGB formats are as follows:
```shell
convert imagem.jpg imagem.rgb
convert -size 320x180 -depth 8 imagem.rgb imagem.png
convert -size 320x180 -depth 8 imagem.rgb imagem.jpg
```

## HSV Color Space
The HSV color space encodes colors into Hue, Saturation, and Value components:
<ul>
<li> Hue represents hue on a color wheel.</li>
<li> Saturation represents the purity of the color. A pure color is said to be saturated. Mixing white,
the color fades and is less saturated. Gray has zero saturation.</li>
<li> Value represents the lighting. The zero value represents darkness, that is, black. A high value
means good lighting and colors are clearly visible.</li>
</ul>

<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/e186bc31-0bdf-4fdd-9a2b-f8252262687e"/>
</div><br>

## Image Segmentation
To find the characters, the first step is to identify the pixels for each. This process is called image
segmentation. Since each character has a different tone from the others, we can only distinguish them
with the Hue component. The tone ranges that can be used for segmentation are shown below.

<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/0b05bad1-5ef4-4ca1-bed9-e90c112ca919"/>
</div><br>

## Center of Mass
In order to calculate the center of mass, the program will traverse the image pixel by pixel. It
will call a function called ’indicator’ that checks if the pixel belongs to the character or not. The
coordinates (cx, cy) correspond to the “center of mass”. If it is, the coordinates of the pixel will be
added to the center of mass values. And every time it hits a valid pixel, a counter will be increased.

<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/460a1dc6-3549-4102-990f-043234a8d333"/>
</div><br>

The calculation is simply the average of the coordinates that belong to the character. The calculation is done in integer arithmetic (do not use floating point instructions).

## C Implementation
There is a [C](https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/tree/master/src/c) implementation of the project in the repository. It is recommended to do the C implementation first before jumping 
into Assembly. These two implementations contain all of the functions described below.

## Functions
There are seven functions in this project. Here are the explanations for each one:

- `main`:
It’s the main function of the program. First, prompts a question to select a character. If it’s chosen
then, call the rest of the functions respectively.<br>

- `read_rgb_image`:
Reads a file with an image in RGB format into an array in memory called `buffer`. It’s a void function
and takes no arguments. First opens the file and checks if there is an exception occurring. Then, reads
the file into `buffer` within the length of `172800` which is the number of all pixels in the image. Then,
closes the file and returns.<br>

- `write_rgb_image`:
Creates a new file with an image in RGB format. It’s a void function and takes no arguments. First
opens a file called `output.rgb` and checks if there is an error or not. Then, write the values of `buffer`
into the file. Then, closes the file and returns.<br>

- `hue`:
Calculates the Hue component from the R, G, and B components of a pixel. Takes three arguments
and returns only one argument which is a0. These arguments are stored in a0, a1, and a2. There are
6 if conditions to find the range of hue value of these RGB values. If those RGB values don’t fit into
any range, the function returns 1, otherwise returns 0.<br>

- `indicator`:
  Indicates whether or not RGB values belong to the character. Takes four arguments and returns only
one argument which is a0. The first argument indicates which character will the function look for.
And the rest represents the RGB values respectively. First calls `hue` function to get the hue value of
these values. And it checks if the hue value fits into the character’s hue interval. if it does return 1,
otherwise returns 0.<br>

- `location`:
  Calculates “center of mass” for the character. Takes two arguments and returns two values. Argument
values are ’character’ and ’ `buffer` address’. It iterates the whole image and calls an `indicator` for each
pixel. If all RGB values are the same, the pixel is not included in the calculation. If the pixel is one
of the pixels of the character, x and y values are added up into registers. And the counter for the
calculation is increased. After the iteration cx and cy values are divided with the counter. The
function returns these values.

  Here is the center of mass values for each character:
<table align="center">
    <thead>
        <tr>
            <th align="left">Character</th>
            <th align="center">Center of Mass</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td align="center">Master Yoda</td>
            <td align="center">67 - 55</td>
        </tr>
        <tr>
            <td align="center">Darth Maul</td>
            <td align="center">66 - 170</td>
        </tr>
        <tr>
            <td align="center">Boba Fett</td>
            <td align="center">65 - 265</td>
        </tr>
    </tbody>
</table>

- `draw_crosshair`:
  Draws a crosshair at the center of mass. Takes three arguments. These are ’`buffer` address’, ’x co-
ordinate of the center of mass’ and, ’y coordinate of the center of mass’. Iterates the image with the
given `buffer` address and finds the pixels around the center of mass. Changes the RGB values for
each pixel in order to draw a pure red crosshair at the center of mass. It does not return anything
since it’s a void function.

## Output
Here is a sample output for Master Yoda:

<div align="center">
    <img src="https://github.com/CheesyFrappe/riscv-center-of-mass-indicator/assets/80858788/585c47a3-5755-46bb-8261-3b82e239cf89"/>
</div><br>








