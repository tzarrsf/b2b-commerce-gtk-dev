/**
 * @description       : Global test settings for your store so you can define them in one place
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Readiness (2023)
 * @last modified on  : 07-18-2025
 * @last modified by  : Tom Zarr
**/
public with sharing class TestSettings
{
    //TODO: Set this to a known good value for your Network (Experience Cloud Site) - Names are CaSe SenSiTIve
    public static final String KNOWN_GOOD_NETWORK_NAME = 'B2B LWR Enhanced Store from TSO';

    //TODO: Set this to a known good value for your WebStore (Commerce Store) - Your Store's Name will almost always be the same as your Network's Name
    public static final String KNOWN_GOOD_WEB_STORE_NAME = 'B2B LWR Enhanced Store from TSO';

    //TODO: Set this to a known good Account in the System
    public static final String KNOWN_GOOD_ACCOUNT_NAME = 'United Coffee Bean Corp';

    //TODO: Set this to a known good first and last name value in the System for a Contact with a User entity and ideally Buyer rights tied to the known good Account above
    public static final String KNOWN_GOOD_BUYER_CONTACT_FIRST_NAME = 'Lauren';
    public static final String KNOWN_GOOD_BUYER_CONTACT_LAST_NAME = 'Boyle';

    //TODO: Set this to a known good Price Adjustment Schedule Name
    public static final String KNOWN_GOOD_PRICE_ADJUSTMENT_SCHEDULE_NAME = 'Seasonal Sale';

    //TODO: Set this to a known good Product Catalog Name
    public static final string KNOWN_GOOD_PRODUCT_CATALOG_NAME = 'B2B LWR Enhanced Store from TSO Catalog';

    //TODO: Set this to a known good Product Category Name
    public static final string KNOWN_GOOD_PRODUCT_CATEGORY_NAME = 'Coffee Machines';

    //TODO: Set this to a known good Product Name
    public static final string KNOWN_GOOD_PRODUCT_NAME_MACHINE = 'The Infuser (Sample)';
    public static final string KNOWN_GOOD_PRODUCT_NAME_BEAN = 'Dark Roast Whole Bean Coffee (Sample)';
    public static final string KNOWN_GOOD_PRODUCT_NAME_MUG = 'Midnight Roast Mug - Scorpio';
    public static final string KNOWN_GOOD_PRODUCT_NAME_WITH_PRICE_SCHEDULE = 'The Infuser (Sample)';

    //TODO: Set these to known good Order Management / Omnichannel Inventory Settings
    public static final string KNOWN_GOOD_LOCATION_GROUP_NAME = 'LocationGroup01';
    public static final string KNOWN_GOOD_LOCATION_NAME = 'Warehouse01';

    // This is the known set of Capricorn Coffee Product Names but you can fill it with whatever you want
    public static final String[] KNOWN_GOOD_PRODUCT_NAMES_SAMPLES = new String[] {
        'Bella Chrome Coffee Machine (Sample)',
        'EspresSmart Espresso Machine (Sample)',
        'Capricorn I Group Espresso Machine (Sample)',
        'The Elite (Sample)',
        'The Infuser (Sample)',
        'Testa Rossa Coffee Machine (Sample)',
        'Dark Roast Whole Bean Coffee (Sample)',
        'Medium Roast Coffee (Sample)',
        'Costa Rican Decaf Roast Bean Bag (Sample)'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_NAMES_MACHINES = new String[] {
        'Prosumer Elite',
        'Bella Chrome Coffee Machine (Sample)',
        'EspresSmart Espresso Machine (Sample)',
        'Capricorn I Group Espresso Machine (Sample)',
        'The Elite (Sample)',
        'The Infuser (Sample)',
        'Testa Rossa Coffee Machine (Sample)'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_NAMES_BEANS = new String[] {
        'Dark Roast Whole Bean Coffee (Sample)',
        'Medium Roast Coffee (Sample)',
        'Costa Rican Decaf Roast Bean Bag (Sample)',
        'Sampler Pack',
        'Onyx Coffee Beans',
        'Obsidian Coffee Beans',
        'Raven Coffee Beans',
        'Pitch Coffee Beans'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_NAMES_MUGS = new String[] {
        'Midnight Roast Mug - Aries',
        'Midnight Roast Mug - Cancer',
        'Midnight Roast Mug - Capricorn',
        'Midnight Roast Mug - Leo',
        'Midnight Roast Mug - Scorpio'
    };

    public static final String KNOWN_GOOD_PRODUCT_CODE_MACHINE = 'B-C-COFMAC-001';
    public static final String KNOWN_GOOD_PRODUCT_SKU_MACHINE = KNOWN_GOOD_PRODUCT_CODE_MACHINE;
    public static final String KNOWN_GOOD_PRODUCT_CODE_BEAN = 'MID-RST-OBSIDIAN';
    public static final String KNOWN_GOOD_PRODUCT_SKU_BEAN = KNOWN_GOOD_PRODUCT_CODE_BEAN;
    public static final String KNOWN_GOOD_PRODUCT_CODE_MUG = 'MID-RST-MUG-CANCER';
    public static final String KNOWN_GOOD_PRODUCT_SKU_MUG = KNOWN_GOOD_PRODUCT_CODE_MUG;

    // This is the known set of Capricorn Coffee Product Codes but you can fill it with whatever you want
    public static final String[] KNOWN_GOOD_PRODUCT_CODES_SAMPLES = new String[] {
        'B-C-COFMAC-001',
        'CR-DEC',
        'DRW-1',
        'ESP-IOT-1',
        'ID-PEM',
        'MRC-1',
        'PS-EL',
        'PS-INF',
        'TR-COFMAC-001'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_SKUS_SAMPLES = KNOWN_GOOD_PRODUCT_CODES_SAMPLES;

    // This is the known good value for the Prosumer Machine added in previous exercises
    public static final String[] KNOWN_GOOD_PRODUCT_CODES_FOR_MACHINES = new String[] {
        'PROSE',
        'B-C-COFMAC-001',
        'ESP-IOT-1',
        'ID-PEM',
        'PS-EL',
        'PS-INF',
        'TR-COFMAC-001'
    };

    public static final String [] KNOWN_GOOD_PRODUCT_SKUS_FOR_MACHINES = KNOWN_GOOD_PRODUCT_CODES_FOR_MACHINES;

    // This is the known good set of values for the Mugs added in previous exercises
    public static final String[] KNOWN_GOOD_PRODUCT_CODES_FOR_BEANS = new String[] {
        'MID-RST-OBSIDIAN',
        'MID-RST-ONYX',
        'MID-RST-PITCH',
        'MID-RST-RAVEN',
        'MID-RST-SAMPLER',
        'DRW-1',
        'MRC-1',
        'CR-DEC'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_SKUS_FOR_BEANS = KNOWN_GOOD_PRODUCT_CODES_FOR_BEANS;

    public static final String[] KNOWN_GOOD_PRODUCT_CODES_FOR_MUGS = new String[] {
        'MID-RST-MUG-CANCER',
        'MID-RST-MUG-SCORPIO',
        'MID-RST-MUG-LEO',
        'MID-RST-MUG-ARIES',
        'MID-RST-MUG-CAPRICORN'
    };

    public static final String[] KNOWN_GOOD_PRODUCT_SKUS_FOR_MUGS = KNOWN_GOOD_PRODUCT_CODES_FOR_MUGS;
}