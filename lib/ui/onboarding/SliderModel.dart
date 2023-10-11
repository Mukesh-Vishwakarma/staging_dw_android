
class SliderModel{
  String? image;
  String? title;
  String? description;

  SliderModel({this.image, this.title, this.description});

  void setData(String getImage, String getTitle, String getDescription){
    image = getImage;
    title = getTitle;
    description = getDescription;
  }

}

List<SliderModel> getSlides(){
  List<SliderModel> slides = <SliderModel>[];
  SliderModel sliderModel = SliderModel();

  sliderModel.setData(
      "assets/images/hero1.png",
      "Welcome to\nRevuER", // Welcome to the\nRevuer app! --> before
      "Sample, Review & Earn " // You will get quick and easy payment\nin your bank account or wallet -->> before
  );
  slides.add(sliderModel);

  sliderModel = SliderModel();

  sliderModel.setData(
      "assets/images/hero2.png",
      "Participate in\nCampaigns", //Participate in\nCampaign -->>before
      "Get quick and easy payments\ninto your bank account" //Let’s explore RevuER and participate\nin your first campaign --->>before
  );
  slides.add(sliderModel);

  sliderModel = SliderModel();

  sliderModel.setData(
      "assets/images/hero3.png",
      "Earn a steady\nincome!", //Earn money easily\nat home! -->>before
      "Earn money by sharing and\nreviewing brands you use and love."
  );
  slides.add(sliderModel);

  sliderModel = SliderModel();

  return slides;
}