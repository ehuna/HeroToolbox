// --------------------------------------------------------------------------------------------------------------------
// <copyright file="StringExtensionsTests.cs" company="hero">
//   MIT License
// </copyright>
// <summary>
//   Defines the StringExtensionsTests type.
// </summary>
// --------------------------------------------------------------------------------------------------------------------

namespace Hero.Toolbox.Tests.Unit.Common.Pcl.Extensions
{
    using Hero.Toolbox.Common.Pcl.Extensions;
    using Xunit;

    /// <summary>
    /// The string extensions tests.
    /// </summary>
    public class StringExtensionsTests
    {
        /// <summary>
        /// The when a string is null or empty has returns false tests.
        /// </summary>
        /// <param name="inputString">
        /// The input string.
        /// </param>
        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData(" ")]
        [InlineData("  ")]
        public void WhenAStringIsNullOrEmptyHasReturnsFalse(string inputString)
        {
            var expectedResult = false;
            var result = inputString.Has();

            Assert.Equal(expectedResult, result);
        }
    }
}
