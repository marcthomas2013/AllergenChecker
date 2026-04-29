import Foundation

struct CommonAllergen: Identifiable, Hashable {
    let name: String
    let aliases: [String]

    var id: String {
        name
    }
}

enum CommonAllergenCatalog {
    static let allergens: [CommonAllergen] = [
        CommonAllergen(name: "Almonds", aliases: ["almond"]),
        CommonAllergen(name: "Apples", aliases: ["apple"]),
        CommonAllergen(name: "Avocado", aliases: ["avocados"]),
        CommonAllergen(name: "Bananas", aliases: ["banana"]),
        CommonAllergen(name: "Beans", aliases: ["bean", "black bean", "broad bean", "kidney bean", "navy bean", "pinto bean"]),
        CommonAllergen(name: "Beef", aliases: ["gelatin", "gelatine"]),
        CommonAllergen(name: "Brazil nuts", aliases: ["brazil nut"]),
        CommonAllergen(name: "Buckwheat", aliases: ["soba"]),
        CommonAllergen(name: "Carrots", aliases: ["carrot"]),
        CommonAllergen(name: "Cashews", aliases: ["cashew"]),
        CommonAllergen(name: "Celery", aliases: ["celeriac"]),
        CommonAllergen(name: "Chickpeas", aliases: ["chickpea", "besan", "chana", "gram flour", "hummus"]),
        CommonAllergen(name: "Citrus fruit", aliases: ["grapefruit", "lemon", "lime", "orange"]),
        CommonAllergen(name: "Coconut", aliases: ["coconuts"]),
        CommonAllergen(name: "Cereals containing gluten", aliases: ["barley", "oats", "rye", "spelt", "wheat"]),
        CommonAllergen(name: "Corn", aliases: ["maize", "cornflour", "corn flour", "corn starch", "cornstarch"]),
        CommonAllergen(name: "Crustaceans", aliases: ["crab", "crayfish", "lobster", "prawn", "shrimp"]),
        CommonAllergen(name: "Eggs", aliases: ["egg", "albumen"]),
        CommonAllergen(name: "Fish", aliases: ["anchovy", "cod", "haddock", "salmon", "tuna"]),
        CommonAllergen(name: "Garlic", aliases: ["garlic powder"]),
        CommonAllergen(name: "Hazelnuts", aliases: ["hazelnut"]),
        CommonAllergen(name: "Kiwi", aliases: ["kiwifruit"]),
        CommonAllergen(name: "Latex-associated foods", aliases: ["avocado", "banana", "chestnut", "kiwi"]),
        CommonAllergen(name: "Lentils", aliases: ["lentil", "red lentil", "green lentil"]),
        CommonAllergen(name: "Legumes and pulses", aliases: ["bean", "beans", "chickpea", "chickpeas", "lentil", "lentils", "pea", "peas", "pulse", "pulses"]),
        CommonAllergen(name: "Lupin", aliases: ["lupine"]),
        CommonAllergen(name: "Macadamia nuts", aliases: ["macadamia", "macadamia nut"]),
        CommonAllergen(name: "Milk", aliases: ["casein", "lactose", "whey"]),
        CommonAllergen(name: "Molluscs", aliases: ["clam", "mussel", "oyster", "scallop", "squid"]),
        CommonAllergen(name: "Mustard", aliases: ["mustard seed"]),
        CommonAllergen(name: "Oats", aliases: ["oat", "oatmeal"]),
        CommonAllergen(name: "Onion", aliases: ["onions", "onion powder"]),
        CommonAllergen(name: "Peas", aliases: ["pea", "pea protein"]),
        CommonAllergen(name: "Peanuts", aliases: ["peanut", "groundnut"]),
        CommonAllergen(name: "Pecans", aliases: ["pecan"]),
        CommonAllergen(name: "Pine nuts", aliases: ["pine nut"]),
        CommonAllergen(name: "Pistachios", aliases: ["pistachio"]),
        CommonAllergen(name: "Pork", aliases: ["porcine", "pork gelatin", "pork gelatine"]),
        CommonAllergen(name: "Potatoes", aliases: ["potato", "potato starch"]),
        CommonAllergen(name: "Rice", aliases: ["rice flour", "rice starch"]),
        CommonAllergen(name: "Seeds", aliases: ["chia", "flax", "linseed", "poppy seed", "pumpkin seed", "sunflower seed"]),
        CommonAllergen(name: "Sesame", aliases: ["sesame seed", "tahini"]),
        CommonAllergen(name: "Shellfish", aliases: ["crustacean", "crustaceans", "mollusc", "molluscs"]),
        CommonAllergen(name: "Soya", aliases: ["soy", "soybean"]),
        CommonAllergen(name: "Strawberries", aliases: ["strawberry"]),
        CommonAllergen(name: "Sulphur dioxide and sulphites", aliases: ["sulfites", "sulphites"]),
        CommonAllergen(name: "Sunflower", aliases: ["sunflower seed", "sunflower oil"]),
        CommonAllergen(name: "Tomatoes", aliases: ["tomato"]),
        CommonAllergen(name: "Tree nuts", aliases: ["almond", "brazil nut", "cashew", "hazelnut", "macadamia", "pecan", "pistachio", "walnut"]),
        CommonAllergen(name: "Walnuts", aliases: ["walnut"]),
        CommonAllergen(name: "Wheat", aliases: ["bran", "bulgur", "couscous", "durum", "semolina"])
    ]
}
