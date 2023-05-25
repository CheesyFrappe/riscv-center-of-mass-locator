#define WIDTH 320
#define HEIGHT 180

void read_rgb_image(char fileName[], unsigned char *arr);
void write_rgb_image(unsigned char *arr);
int hue(int r, int g, int b);
int indicator(int c, int r, int g, int b);
void location(int c, unsigned char *arr);
