using System;
using NUnit.Framework;
using Calculator;

namespace TestCalculator
{
    [TestFixture]
    public class CalculatorTests
    {
        private Calculator.Calculator _calculator;

        [SetUp]
        public void Setup()
        {
            _calculator = new Calculator.Calculator();
        }

        #region Add Tests

        [Test]
        public void Add_TwoPositiveNumbers_ReturnsCorrectSum()
        {
            // Arrange
            double a = 5;
            double b = 3;

            // Act
            double result = _calculator.Add(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(8));
        }

        [Test]
        public void Add_TwoNegativeNumbers_ReturnsCorrectSum()
        {
            // Arrange
            double a = -5;
            double b = -3;

            // Act
            double result = _calculator.Add(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(-8));
        }

        [Test]
        public void Add_PositiveAndNegativeNumber_ReturnsCorrectSum()
        {
            // Arrange
            double a = 5;
            double b = -3;

            // Act
            double result = _calculator.Add(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(2));
        }

        #endregion

        #region Subtract Tests

        [Test]
        public void Subtract_TwoPositiveNumbers_ReturnsCorrectDifference()
        {
            // Arrange
            double a = 10;
            double b = 4;

            // Act
            double result = _calculator.Subtract(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(6));
        }

        [Test]
        public void Subtract_ResultIsNegative_ReturnsCorrectDifference()
        {
            // Arrange
            double a = 4;
            double b = 10;

            // Act
            double result = _calculator.Subtract(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(-6));
        }

        #endregion

        #region Multiply Tests

        [Test]
        public void Multiply_TwoPositiveNumbers_ReturnsCorrectProduct()
        {
            // Arrange
            double a = 6;
            double b = 7;

            // Act
            double result = _calculator.Multiply(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(42));
        }

        [Test]
        public void Multiply_ByZero_ReturnsZero()
        {
            // Arrange
            double a = 100;
            double b = 0;

            // Act
            double result = _calculator.Multiply(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(0));
        }

        [Test]
        public void Multiply_TwoNegativeNumbers_ReturnsPositiveProduct()
        {
            // Arrange
            double a = -5;
            double b = -4;

            // Act
            double result = _calculator.Multiply(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(20));
        }

        #endregion

        #region Divide Tests

        [Test]
        public void Divide_TwoPositiveNumbers_ReturnsCorrectQuotient()
        {
            // Arrange
            double a = 20;
            double b = 4;

            // Act
            double result = _calculator.Divide(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(5));
        }

        [Test]
        public void Divide_ResultIsDecimal_ReturnsCorrectQuotient()
        {
            // Arrange
            double a = 10;
            double b = 4;

            // Act
            double result = _calculator.Divide(a, b);

            // Assert
            Assert.That(result, Is.EqualTo(2.5));
        }

        [Test]
        public void Divide_ByZero_ThrowsDivideByZeroException()
        {
            // Arrange
            double a = 10;
            double b = 0;

            // Act & Assert
            Assert.Throws<DivideByZeroException>(() => _calculator.Divide(a, b));
        }

        #endregion
    }
}
