#include <gb/gb.h>
#include <stdint.h>
#include <gb/drawing.h>
#include "input.h"

typedef struct {
    uint32_t hi;
    uint32_t lo;
} u64;

const u64 ZERO = { 0, 0 };

static const uint32_t POW10_U32[6] = {
    1U,
    10U,
    100U,
    1000U,
    10000U,
    100000U
};

static uint32_t pow10_u32(uint8_t n) {
    return POW10_U32[n];
}

void add_int_to_u64(u64 *n, uint32_t x) {
    uint32_t old_lo = n->lo;
    n->lo += x;
    if (n->lo < old_lo) {
        n->hi += 1U;
    }
}

int u64_is_zero(const u64 *n) {
    return (n->hi == 0 && n->lo == 0);
}

u64 u64_add(u64 a, u64 b) {
    u64 result;
    result.lo = a.lo + b.lo;
    uint32_t carry = (result.lo < a.lo) ? 1U : 0U;
    result.hi = a.hi + b.hi + carry;
    return result;
}

void u64_add_inplace(u64 *dst, const u64 *src) {
    u64 r = u64_add(*dst, *src);
    *dst = r;
}

void u64_shl1(u64 *n) {
    uint32_t carry = n->lo >> 31;
    n->lo <<= 1;
    n->hi = (n->hi << 1) | carry;
}

void u64_mul10_inplace(u64 *n) {
    u64 a = *n;
    u64 b = *n;

    // 2x
    u64_shl1(&a);

    // 8x
    u64_shl1(&b);
    u64_shl1(&b);
    u64_shl1(&b);

    *n = u64_add(a, b);
}

int u64_less_than_or_equal(const u64 *a, const u64 *b) {
    if (a->hi < b->hi) return 1;
    if (a->hi > b->hi) return 0;
    return a->lo <= b->lo;
}

void u64_divmod_u32(u64 n, uint32_t d, u64 *q_out, uint32_t *r_out) {
    uint32_t rem = 0;
    uint32_t q_hi = 0;
    uint32_t q_lo = 0;

    for (int idx = 7; idx >= 0; idx--) {
        uint32_t byte;
        if (idx >= 4) {
            byte = (n.hi >> ((idx - 4) * 8)) & 0xFFU;
        } else {
            byte = (n.lo >> (idx * 8)) & 0xFFU;
        }

        rem = (rem << 8) | byte;
        uint32_t qbyte = rem / d;
        rem = rem % d;

        if (idx >= 4) {
            q_hi |= (qbyte << ((idx - 4) * 8));
        } else {
            q_lo |= (qbyte << (idx * 8));
        }
    }

    q_out->hi = q_hi;
    q_out->lo = q_lo;
    *r_out = rem;
}


int u64_to_str(u64 num, char* str) {
    int i = 0;
    if (u64_is_zero(&num)) {
        str[0] = '0';
        str[1] = '\0';
        return 1;
    }
    while (!u64_is_zero(&num)) {
        uint32_t digit;
        u64_divmod_u32(num, 10U, &num, &digit);
        str[i++] = (char)(digit + '0');
    }
    int halfway_point = i / 2;
    for (int j = 0; j < halfway_point; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
    str[i] = '\0';
    return i;
}

int str_len(const char *s) {
    int n = 0;
    while (s[n] != '\0') {
        n++;
    }
    return n;
}

u64 parse_u64_until(const char **p, char stop) {
    const char *s = *p;
    u64 value;
    value.hi = 0;
    value.lo = 0;

    char c = *s;
    while (c != '\0' && c != stop) {
        if (c < '0' || c > '9') break;
        u64_mul10_inplace(&value);
        add_int_to_u64(&value, (uint32_t)(c - '0'));
        s++;
        c = *s;
    }
    *p = s;
    return value;
}

char* u32_to_str(uint32_t value, char* buffer) {
    char* p = buffer;
    char* start = buffer;
    char tmp;

    do {
        char digit = value % 10U;
        *p++ = ('0' + digit);
        value /= 10U;
    } while (value != 0U);

    *p = '\0';
    p--;

    // reverse
    while (start < p) {
        tmp = *start;
        *start = *p;
        *p = tmp;
        start++;
        p--;
    }

    return buffer;
}

void print_u64(u64 v) {
    char buf[32];
    u64_to_str(v, buf);
    gprintf("%s", buf);
}

uint32_t u64_div_u32_floor(u64 n, uint32_t d) {
    u64 q;
    uint32_t r;
    u64_divmod_u32(n, d, &q, &r);
    return q.lo;
}

uint32_t u64_div_u32_ceil(u64 n, uint32_t d) {
    u64 q;
    uint32_t r;
    u64_divmod_u32(n, d, &q, &r);
    if (r != 0U) {
        add_int_to_u64(&q, 1U);
    }
    return q.lo;
}

void main(void) {
    u64 invalid_id_sum;
    invalid_id_sum.hi = 0;
    invalid_id_sum.lo = 0;

    const char* p = input_data;

    while (*p != '\0') {
        u64 first_num = parse_u64_until(&p, '-');
        if (*p == '-') p++; 

        u64 second_num = parse_u64_until(&p, ',');
        if (*p == ',') p++;

        print_u64(first_num);
        gprintf("...");

        char first_num_str[32];
        char second_num_str[32];
        int first_len  = u64_to_str(first_num,  first_num_str);
        int second_len = u64_to_str(second_num, second_num_str);
        int min_half_len = first_len / 2;
        int max_half_len = second_len / 2;

        for (int half_len = min_half_len; half_len <= max_half_len; half_len++) {

            // all numbers of length half_len (e.g., 10 through 99)
            uint32_t min_num_with_n_digits = pow10_u32(half_len - 1);
            uint32_t max_num_with_n_digits = pow10_u32(half_len) - 1U;

            uint32_t d = pow10_u32(half_len) + 1U; // e.g., 13 - 99 needs to become 14 - 89
            uint32_t min_candidate_half = u64_div_u32_ceil(first_num, d);
            uint32_t max_candidate_half = u64_div_u32_floor(second_num, d);

            // clamping
            if (min_candidate_half < min_num_with_n_digits) min_candidate_half = min_num_with_n_digits;
            if (max_candidate_half > max_num_with_n_digits) max_candidate_half = max_num_with_n_digits;

            // each of these is a legitimate double number
            for (uint32_t candidate_half = min_candidate_half; candidate_half <= max_candidate_half; candidate_half++) {
                char half_buf[16];
                u32_to_str(candidate_half, half_buf);

                char full_buf[32];
                char* fbi = full_buf;

                // copy the number twice
                for (int i = 0; i < half_len * 2; i++) {
                    *fbi = half_buf[i % half_len];
                    fbi++;
                }
                *fbi = '\0';

                const char* q = full_buf;
                u64 invalid_id_num = parse_u64_until(&q, '\0');
                u64_add_inplace(&invalid_id_sum, &invalid_id_num);
            }
        }
    }

    gprintf("            SUM:");
    print_u64(invalid_id_sum);
}

