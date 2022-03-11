public class DatedConversionRateService {
    public static DatedConversionRate getConversionRate(Date dateValue, String currencyCode){
		return [SELECT ConversionRate, IsoCode, StartDate, NextStartDate 
                FROM DatedConversionRate 
                WHERE 
               IsoCode = :currencyCode AND
               StartDate <= :dateValue AND
               NextStartDate > :dateValue];      
    }
}