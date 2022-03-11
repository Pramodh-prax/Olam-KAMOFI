@isTest
public class ProductConfigWrapper_Test {
@isTest
    public static void test()
    {
        ProductConfigWrapper prodConfigWrap = new ProductConfigWrapper();
        prodConfigWrap.mic = '-U100';
        prodConfigWrap.varient_character_mapping = 'Test';
        prodConfigWrap.description = 'MOLD COUNT PER GRAM';
        prodConfigWrap.uom = '%';
        prodConfigWrap.quantitative = 'Yes';
        prodConfigWrap.qualitative = '';
        prodConfigWrap.olam_range = '0,00 - 500,00';
        prodConfigWrap.customer_range = '0,000 - 500,000';
        prodConfigWrap.category='abc';
    }
}