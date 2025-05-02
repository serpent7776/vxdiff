#include <stdio.h>
#include <stdlib.h>
#include <spng.h>
#include <string.h>

size_t vxdiff(const uint8_t* base_image, const uint8_t* second_image,
            uint64_t base_width, uint64_t second_width,
            uint64_t base_height, uint64_t second_height);

int compare_images(const char* path1, const char* path2) {
	spng_ctx *ctx1 = NULL, *ctx2 = NULL;
	void *out1 = NULL, *out2 = NULL;
	FILE *file1 = NULL, *file2 = NULL;
	size_t out_size1, out_size2;
	int ret;
	struct spng_ihdr ihdr1, ihdr2;

	file1 = fopen(path1, "rb");
	file2 = fopen(path2, "rb");
	if (!file1 || !file2) {
		fprintf(stderr, "Error opening files\n");
		return 1;
	}

	ctx1 = spng_ctx_new(0);
	ctx2 = spng_ctx_new(0);
	if (!ctx1 || !ctx2) {
		fprintf(stderr, "Error creating contexts\n");
		return 1;
	}

	spng_set_png_file(ctx1, file1);
	spng_set_png_file(ctx2, file2);

	ret = spng_get_ihdr(ctx1, &ihdr1);
	if (ret) {
		fprintf(stderr, "Error getting header for image 1\n");
		return 1;
	}

	ret = spng_get_ihdr(ctx2, &ihdr2);
	if (ret) {
		fprintf(stderr, "Error getting header for image 2\n");
		return 1;
	}

	if (ihdr1.width != ihdr2.width || ihdr1.height != ihdr2.height) {
		fprintf(stderr, "Images have different dimensions\n");
		return 1;
	}

	ret = spng_decoded_image_size(ctx1, SPNG_FMT_RGBA8, &out_size1);
	ret |= spng_decoded_image_size(ctx2, SPNG_FMT_RGBA8, &out_size2);
	if (ret || out_size1 != out_size2) {
		fprintf(stderr, "Error calculating output sizes\n");
		return 1;
	}

	out1 = malloc(out_size1);
	out2 = malloc(out_size2);
	if (!out1 || !out2) {
		fprintf(stderr, "Memory allocation failed\n");
		return 1;
	}

	ret = spng_decode_image(ctx1, out1, out_size1, SPNG_FMT_RGBA8, 0);
	if (ret) {
		fprintf(stderr, "Error decoding image 1\n");
		return 1;
	}

	ret = spng_decode_image(ctx2, out2, out_size2, SPNG_FMT_RGBA8, 0);
	if (ret) {
		fprintf(stderr, "Error decoding image 2\n");
		return 1;
	}

	const size_t differences = vxdiff(out1, out2, ihdr1.width, ihdr2.width, ihdr1.height, ihdr2.height);

	printf("Total differences found: %zu\n", differences);
	return 0;
}

int main(int argc, char *argv[]) {
	if (argc != 3) {
		fprintf(stderr, "Usage: %s <image1.png> <image2.png>\n", argv[0]);
		return 2;
	}

	return compare_images(argv[1], argv[2]);
}
