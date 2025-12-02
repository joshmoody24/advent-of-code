#include <gb/gb.h>
#include <stdint.h>
#include <gb/drawing.h>
#include "input.h"

typedef struct {
  unsigned long hi;
  unsigned long lo;
} u64;

const u64 ZERO = { 0, 0 };

void add_int_to_u64(u64 *n, unsigned long x) {
  unsigned long old_lo = n->lo;
  n->lo += x;
  if (n->lo < old_lo) {
    n->hi += 1;
  }
}

int is_zero_u64(const u64 *n) {
  return (n->hi == 0 && n->lo == 0);
}

u64 u64_add(u64 a, u64 b) {
  u64 result;
  result.lo = a.lo + b.lo;
  unsigned long carry = (result.lo < a.lo) ? 1UL : 0UL;
  result.hi = a.hi + b.hi + carry;
  return result;
}

void u64_add_inplace(u64 *dst, const u64 *src) {
  u64 r = u64_add(*dst, *src);
  *dst = r;
}

void u64_shl1(u64 *n) {
  unsigned long carry = n->lo >> 31;
  n->lo <<= 1;
  n->hi = (n->hi << 1) | carry;
}

void u64_mul10_inplace(u64 *n) {
  u64 a = *n;
  u64 b = *n;
  u64_shl1(&a);
  u64_shl1(&b);
  u64_shl1(&b);
  u64_shl1(&b);
  *n = u64_add(a, b);
}

int u64_le(const u64 *a, const u64 *b) {
  if (a->hi < b->hi) return 1;
  if (a->hi > b->hi) return 0;
  return a->lo <= b->lo;
}

void u64_inc(u64 *n) {
  add_int_to_u64(n, 1);
}

void u64_divmod_small(u64 n, unsigned int d, u64 *q_out, unsigned int *r_out) {
  unsigned long rem = 0;
  unsigned long q_hi = 0;
  unsigned long q_lo = 0;

  for (int idx = 7; idx >= 0; idx--) {
    unsigned long byte;
    if (idx >= 4) {
      byte = (n.hi >> ((idx - 4) * 8)) & 0xFFUL;
    } else {
      byte = (n.lo >> (idx * 8)) & 0xFFUL;
    }

    rem = rem * 256UL + byte;
    unsigned long qbyte = rem / d;
    rem = rem % d;

    if (idx >= 4) {
      q_hi |= (qbyte << ((idx - 4) * 8));
    } else {
      q_lo |= (qbyte << (idx * 8));
    }
  }

  q_out->hi = q_hi;
  q_out->lo = q_lo;
  *r_out = (unsigned int)rem;
}

unsigned int u64_divmod_small_inplace(u64 *n, unsigned int d) {
  u64 q;
  unsigned int r;
  u64_divmod_small(*n, d, &q, &r);
  *n = q;
  return r;
}

int u64_to_str(u64 num, char* str) {
  int i = 0;
  if (is_zero_u64(&num)) {
    str[0] = '0';
    str[1] = '\0';
    return 1;
  }
  while (!is_zero_u64(&num)) {
    unsigned int digit = u64_divmod_small_inplace(&num, 10);
    str[i] = (char)(digit + '0');
    i++;
  }
  char halfway_point = i / 2;
  for (char j = 0; j < halfway_point; j++) {
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

int str_is_two_equal_substrings(char* str, int len){
  if(len % 2 != 0){
    return 0;
  }
  char substring_len = str_len(str) / 2;
  for (int i = 0; i < substring_len; i++) {
    char ci = str[i];
    char cj = str[i + substring_len];
    if (ci != cj) {
      return 0;
    }
  }
  return 1;
}

u64 parse_u64_until(const char **p, char stop1, char stop2) {
  const char *s = *p;
  u64 value = { 0, 0 };
  char c = *s;
  while (c != '\0' && c != stop1 && c != stop2) {
    if (c < '0' || c > '9') break;
    u64_mul10_inplace(&value);
    add_int_to_u64(&value, (unsigned long)(c - '0'));
    s++;
    c = *s;
  }
  *p = s;
  return value;
}

// returns the next position in the string to start parsing from
const char* add_invalid_ids_from_range(const char* input, u64* sum) {
  const char *p = input;
  char current = *p;
  if (current == '\0') return p;

  u64 first_num = parse_u64_until(&p, '-', '\0');
  if (*p == '\0') return p;
  if (*p == '-') p++;
  u64 second_num = parse_u64_until(&p, ',', '\0');
  current = *p;

  u64 i = first_num;
  unsigned long counter = 0;
  while (u64_le(&i, &second_num)) {
    if ((counter & 0xFF) == 0) {
      gprintf(".");
    }
    counter++;
    char iStr[64];
    if (str_is_two_equal_substrings(iStr, u64_to_str(i, iStr))) {
      u64_add_inplace(sum, &i);
    }
    u64_inc(&i);
  }

  gprintf("o");

  if (current == ',') {
    return p + 1;
  } else {
    return p;
  }
}

void main(void) {
  u64 invalid_id_sum = { 0, 0 };
  const char* current_position = input_data;
  while (*current_position != '\0') {
    const char* next_pos = add_invalid_ids_from_range(current_position, &invalid_id_sum);
    if (next_pos == 0){
      break;
    }
    if (next_pos == current_position) {
      break;
    }
    current_position = next_pos;
  }
  char buf[64];
  u64_to_str(invalid_id_sum, buf);
  gprintf("Invalid IDs sum: %s", buf);
}

