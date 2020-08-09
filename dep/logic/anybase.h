//
//  anybase.h
//  remotekb
//
//  Created by everettjf on 2019/7/18.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef anybase_h
#define anybase_h

#include <cstdio>
#include <string>

namespace anybase {
    // To return value of a char. For example, 2 is
    // returned for '2'.  10 is returned for 'A', 11
    // for 'B'
    inline long internal_val(char c)
    {
        if (c >= '0' && c <= '9')
            return (long)c - '0';
        else
            return (long)c - 'a' + 10;
    }
    
    // Function to convert a number from given base 'b'
    // to decimal
    inline long internal_AnyBase2Decimal(const char *str, int base)
    {
        int len = (int)strlen(str);
        int power = 1; // Initialize power of base
        long num = 0;  // Initialize result
        
        // Decimal equivalent is str[len-1]*1 +
        // str[len-1]*base + str[len-1]*(base^2) + ...
        for (int i = len - 1; i >= 0; i--)
        {
            // A digit in input number must be
            // less than number's base
            if (internal_val(str[i]) >= base)
            {
                printf("Invalid Number %c,%d,%d,%s\n", str[i],str[i], base,str);
                return -1;
            }
            
            num += internal_val(str[i]) * power;
            power = power * base;
        }
        return num;
    }
    
    
    // To return char for a value. For example '2'
    // is returned for 2. 'A' is returned for 10. 'B'
    // for 11
    inline char internal_reVal(long num)
    {
        if (num >= 0 && num <= 9)
            return (char)(num + '0');
        else
            return (char)(num - 10 + 'a');
    }
    
    // Utility function to reverse a string
    inline void internal_strev(char *str)
    {
        size_t len = strlen(str);
        int i;
        for (i = 0; i < len/2; i++)
        {
            char temp = str[i];
            str[i] = str[len-i-1];
            str[len-i-1] = temp;
        }
    }
    
    // Function to convert a given decimal number
    // to a base 'base' and
    inline char* internal_Decimal2AnyBase(char res[], long inputNum, int base)
    {
        int index = 0;  // Initialize index of result
        
        // Convert input number is given base by repeatedly
        // dividing it by base and taking remainder
        while (inputNum > 0) {
            res[index++] = internal_reVal(inputNum % base);
            inputNum /= base;
        }
        res[index] = '\0';
        
        // Reverse the result
        internal_strev(res);
        
        return res;
    }
    
    
    inline long AnyBase2Decimal(const std::string &value, int base) {
        if(base < 2 || base > 35) {
            return -1;
        }
        
        return internal_AnyBase2Decimal(value.c_str(), base);
    }

    inline std::string Decimal2AnyBase(long value, int base) {
        if(base < 2 || base > 35) {
            return "";
        }
        
        char res[100] = {0};
        internal_Decimal2AnyBase(res, value, base);
        return std::string(res);
    }
}



#endif /* anybase_h */
