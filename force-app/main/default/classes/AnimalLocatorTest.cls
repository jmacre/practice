@isTest
private class AnimalLocatorTest {

    @isTest
    static void testGetAnimalNameById() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        
        // Act
        Test.startTest();
        String result = AnimalLocator.getAnimalNameById(1);
        Test.stopTest();
        
        // Assert
        System.assertEquals('majestic badger', result);
    }
}
