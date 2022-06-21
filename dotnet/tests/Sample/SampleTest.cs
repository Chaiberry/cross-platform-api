using System;
using Xunit;
using ChaiBerry.CrossPlatformApi.Sample;

namespace CrossPlatformApi.Tests {
  public class SampleTest {
    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public void SimpleTest(bool callGC) {
      if (callGC) {
        GC.Collect();
      }

      var v = csSample.caAdd(4, 5);
      Assert.Equal(9, v);
    }
  }
}
