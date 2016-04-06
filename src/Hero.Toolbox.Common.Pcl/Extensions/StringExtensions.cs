// --------------------------------------------------------------------------------------------------------------------
// <copyright file="StringExtensions.cs" company="hero">
//   MIT License
// </copyright>
// <summary>
//   Defines the StringExtensions type.
// </summary>
// --------------------------------------------------------------------------------------------------------------------

namespace Hero.Toolbox.Common.Pcl.Extensions
{
    /// <summary>
    /// The string extensions.
    /// </summary>
    public static class StringExtensions
    {
        /// <summary>
        /// Returns true if string is NOT (null, empty or white space)
        /// </summary>
        /// <param name="source">
        /// The source.
        /// </param>
        /// <returns>
        /// The <see cref="bool"/>.
        /// </returns>
        public static bool Has(this string source)
        {
            return !string.IsNullOrWhiteSpace(source);
        }
    }
}
