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
        CommonAllergen(name: "Celery", aliases: ["celeriac"]),
        CommonAllergen(name: "Cereals containing gluten", aliases: ["barley", "oats", "rye", "spelt", "wheat"]),
        CommonAllergen(name: "Crustaceans", aliases: ["crab", "crayfish", "lobster", "prawn", "shrimp"]),
        CommonAllergen(name: "Eggs", aliases: ["egg", "albumen"]),
        CommonAllergen(name: "Fish", aliases: ["anchovy", "cod", "haddock", "salmon", "tuna"]),
        CommonAllergen(name: "Lupin", aliases: ["lupine"]),
        CommonAllergen(name: "Milk", aliases: ["casein", "lactose", "whey"]),
        CommonAllergen(name: "Molluscs", aliases: ["clam", "mussel", "oyster", "scallop", "squid"]),
        CommonAllergen(name: "Mustard", aliases: ["mustard seed"]),
        CommonAllergen(name: "Peanuts", aliases: ["peanut", "groundnut"]),
        CommonAllergen(name: "Sesame", aliases: ["sesame seed", "tahini"]),
        CommonAllergen(name: "Soya", aliases: ["soy", "soybean"]),
        CommonAllergen(name: "Sulphur dioxide and sulphites", aliases: ["sulfites", "sulphites"]),
        CommonAllergen(name: "Tree nuts", aliases: ["almond", "brazil nut", "cashew", "hazelnut", "macadamia", "pecan", "pistachio", "walnut"])
    ]
}
