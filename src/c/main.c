#include <stdio.h>
#include <stdlib.h>
#include "main.h"

int cx; // r0w
int cy; // c0lumn

void main(int argc, char *argv[])
{
    unsigned char imageArray[WIDTH * HEIGHT * 3];
    int p;
    int count = 0;

    printf("1=>Yoda\n2=>Maul\n3=>Mando\nselect character: ");
    scanf("%d", &p);

    while (p > 3 || p < 0)
    {
        printf("select character: ");
        scanf("%d", &p);
    }

    read_rgb_image("starwars.rgb", imageArray);
    location(p, imageArray);
    // printf("%d\n", indicator(1, 69, 89, 89));
    // printf("%d\n", hue(67, 255, 255));
    printf("%d - %d\n", cx, cy);
    write_rgb_image(imageArray);
}

// reads a file with an image in RGB format into an array in memory
void read_rgb_image(char fileName[], unsigned char *arr)
{
    FILE *image;
    image = fopen(fileName, "rb");

    if (!image)
    {
        printf("unable to open file\n");
        exit(1);
    }

    fread(arr, 3, WIDTH * HEIGHT, image);
    fclose(image);
}

// creates a new file with an image in RGB format
void write_rgb_image(unsigned char *arr)
{
    int x = 0;
    int y = 0;
    FILE *image;
    image = fopen("output.rgb", "wb");

    if (!image)
    {
        printf("unable to write file\n");
        exit(1);
    }

    for (int i = 0; i < WIDTH * HEIGHT * 3; i += 3)
    {
        if (y == 320)
        {
            x++;
            y = 0;
        }
        if (x == cx && y == cy)
        {
            // red dot
            arr[i] = 255;
            arr[i + 1] = 0;
            arr[i + 2] = 0;
            break;
        }
        y++;
    }

    fwrite(arr, 3, WIDTH * HEIGHT, image);
    fclose(image);
}

// calculates Hue component from R, G and B components of a pixel
int hue(int r, int g, int b)
{
    if (r > g && g >= b)
    {
        return (60 * (g - b)) / (r - b);
    }
    else if (g >= r && r > b)
    {
        return 120 - ((60 * (r - b)) / (g - b));
    }
    else if (g > b && b >= r)
    {
        return 120 + ((60 * (b - r)) / (g - r));
    }
    else if (b >= g && g > r)
    {
        return 240 - ((60 * (g - r)) / (b - r));
    }
    else if (b > r && r >= g)
    {
        return 240 + ((60 * (r - g)) / (b - g));
    }
    else if (r >= b && b > g) //
    {
        return 360 - ((60 * (b - g)) / (r - g));
    }
    else
    {
        printf("test");
    }
}

// indicates whether or not RGB values belongs to character
int indicator(int c, int r, int g, int b)
{
    int hue_value = hue(r, g, b);

    // yoda
    if (c == 1)
    {
        return (hue_value >= 40 && hue_value <= 80);
    }
    // maul
    else if (c == 2)
    {
        return (hue_value >= 1 && hue_value <= 15);
    }
    // mando
    else
    {
        return (hue_value >= 160 && hue_value <= 180);
    }
}

// calculates “center of mass” for a certain character
void location(int c, unsigned char *arr)
{
    int q = 0;

    int x = 0;
    int y = 0;
    int count = 0;

    for (int i = 0; i < WIDTH * HEIGHT * 3; i += 3)
    {

        if (y == 320)
        {
            x++;
            y = 0;
        }

        if (arr[i] == arr[i + 1] && arr[i + 1] == arr[i + 2])
        {
            q++;
            y++;
            continue;
        }

        if (indicator(c, arr[i], arr[i + 1], arr[i + 2]))
        {
            // printf("%d, %d, %d\n", arr[i], arr[i + 1], arr[i + 2]);
            count++;
            cx += x;
            cy += y;
        }
        y++;
        // printf("%d\n", i);
        // printf("%d, %d, %d\n", arr[i], arr[i + 1], arr[i + 2]);
    }
    printf("%d\n", cx);
    printf("%d\n", cy);
    printf("%d\n", count);
    cx /= count;
    cy /= count;
}
// yoda
// 67, 55
// total 11370

/*
    la a0, buff
    addi a0, a0, 3
    lbu a1, 0(a0)
    mv a0, a1
    li a7, 1
    ecall
*/