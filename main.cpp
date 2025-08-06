#include <iostream>
#include <vector>
#include <string>

#include <memory>
#include <mutex>
#include <vector>
#include <thread>
#include <atomic>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

class Calculator
{
private:
    int result;

public:
    Calculator() : result(0) {}

    void add(int value)
    {
        result += value;
        std::cout << "Added " << value << ", result: " << result << std::endl;
    }

    void subtract(int value)
    {
        result -= value;
        std::cout << "Subtracted " << value << ", result: " << result << std::endl;
    }

    void multiply(int value)
    {
        result *= value;
        std::cout << "Multiplied by " << value << ", result: " << result << std::endl;
    }

    int getResult() const
    {
        return result;
    }

    void reset()
    {
        result = 0;
        std::cout << "Reset calculator, result: " << result << std::endl;
    }
};

void printVector(const std::vector<int> &vec)
{
    std::cout << "Vector contents: ";
    for (size_t i = 0; i < vec.size(); ++i)
    {
        std::cout << vec[i];
        if (i < vec.size() - 1)
        {
            std::cout << ", ";
        }
    }
    std::cout << std::endl;
}

int factorial(int n)
{
    if (n <= 1)
    {
        return 1;
    }
    return n * factorial(n - 1);
}

int main()
{
    std::cout << "=== Remote Debug Demo Program ===6666666" << std::endl;

    // Create calculator instance
    Calculator calc;

    // Test calculator operations
    calc.add(10);
    calc.subtract(3);
    calc.multiply(2);

    std::cout << "Final calculator result: " << calc.getResult() << std::endl;

    // Test vector operations
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    printVector(numbers);

    // Add some numbers to vector
    for (int i = 6; i <= 10; ++i)
    {
        numbers.push_back(i);
    }
    printVector(numbers);

    // Test factorial function
    int n = 5;
    int fact = factorial(n);
    std::cout << "Factorial of " << n << " is: " << fact << std::endl;

    // Interactive input section
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);

    if (!name.empty())
    {
        std::cout << "Hello, " << name << "!" << std::endl;
    }
    else
    {
        std::cout << "Hello, anonymous user!" << std::endl;
    }

    // Demonstrate some debugging scenarios
    int debugVar = 42;
    std::cout << "Debug variable value: " << debugVar << std::endl;

    // Loop with potential breakpoint
    for (int i = 0; i < 5; ++i)
    {
        std::cout << "Loop iteration: " << i << std::endl;
        debugVar += i;
    }

    std::cout << "Final debug variable value: " << debugVar << std::endl;
    std::cout << "Program completed successfully!" << std::endl;

    return 0;
}