//
//  ViewController.m
//  ADAM by Noscio
//
//  Created by Jonathan Lucas Fritz on 12.08.16.
//  Copyright © 2016 NOSCIO. All rights reserved.
//

#import "ViewController.h"
#import "ADAMCom.h"
#import "ADAMerci.h"
#import "ADAM_MapView.h"
#import "MBProgressHUD.h"
#import "CheckConnection.h"
#import "outrepasser.h"

@interface ViewController ()<CLLocationManagerDelegate>

@end
ADAM_MapView *mapView;
NSMutableDictionary *dictim;
NSMutableArray *nummerext;
NSMutableArray *stationlong;
NSMutableDictionary *nummerbahn;
ADAMerci *baguette;
MBProgressHUD *hud;

@implementation ViewController
@synthesize datenschutz;
@synthesize credits;
@synthesize ortung;


- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    [self startupcheck]; //Überprüfe die Verbindung
}
///Verbindung überprüfen und dann starten oder Fehlermeldeung ausgeben
-(void)startupcheck
{
    CheckConnection *checker;
    checker = [[CheckConnection alloc]init];
    
    if ([checker checkfnc]) //Wenn eine Verbindung vorhanden ist
    {
        [self runner];
        
    }
    if (![checker checkfnc]) //Wenn keine Verbindung vorhanden ist
    {
        
        NSTimer *timernew; // Kurzes Delay, dass sich das UI updaten kann
        timernew = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(run_error) userInfo:nil repeats:NO];
    }
}
-(void)runner
{
    
    locationManager = [[CLLocationManager alloc] init]; // Mache dieses blöde Location Manager Zeugs
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [locationManager startUpdatingLocation]; //Starte Location Updates
    
    credits = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 10)]; // Credits Button erstellen
    [credits setBackgroundColor:[UIColor clearColor]];
    [credits.titleLabel setFont:[UIFont systemFontOfSize:self.view.frame.size.height/55]];
    [credits setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [credits setTitle:(@"Daten bereitgestellt von der Deutschen Bahn / ADAM\nFreepik | Creative Commons BY 3.0 | CC 3.0 BY") forState:UIControlStateNormal]; // Text für Credits setzen
    credits.titleLabel.numberOfLines = 2; // Das Ding hat 2 Linien
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES]; //HUD aktivieren und Objekt abgreifen für Modifikationen
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabel.text = (@"Lade Daten vom Server..."); //Schönen Text beim HUD setzen
    
    
    NSTimer *timernew; // Kurzes Delay, dass sich das UI updaten kann
    timernew = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(run_debut) userInfo:nil repeats:NO];
    NSTimer *timernewnew; // Kurzes Delay, dass sich das UI updaten kann
    timernewnew = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(testanother) userInfo:nil repeats:NO];
    
//    http://www.bahnhof.de/bahnhof-de/Lorch__Wuertt_.html?hl=lorch // Ignorieren
    [credits addTarget:self action:@selector(showcreditalert) forControlEvents:UIControlEventPrimaryActionTriggered]; // Die Action für den Credits Button setzen
    
    credits.titleLabel.textAlignment = NSTextAlignmentCenter; //Text Aligment setzen
//    credits.titleLabel.font = [UIFont boldSystemFontOfSize:credits.titleLabel.font.pointSize];
    
}
///Die Methode hat nen blöden Namen weil ich was testen wollte, hab aber keine Lust das zu ändern - funktioniert jetzt ja
-(void)testanother
{
//    NSString *urlstring;
//    urlstring = (@"https://noscio.eu/ADAM/stationsdaten.json"); //Hier liegen die Aufzugsdaten
//    
//    NSURL *url=[NSURL URLWithString:urlstring];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    [request setHTTPMethod:@"GET"];
//    
//    NSError *error;
//    NSURLResponse *response;
//    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    
//
    
    NSURL *imgPath = [[NSBundle mainBundle] URLForResource:@"stationsdaten" withExtension:@"json"];
    NSString*stringPath = [imgPath absoluteString]; //this is correct
    
    //you can again use it in NSURL eg if you have async loading images and your mechanism
    //uses only url like mine (but sometimes i need local files to load)
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    dictim = [self dicfromdata:data]; //Aufzugsdaten in Dictionary schieben
    fullele = [dictim mutableCopy];
    
    nummerext = [dictim valueForKeyPath:@"Equipment"]; //Alle Equip abgreifen
    stationlong = [dictim valueForKeyPath:@"Ort"]; // Alle Orte abgreifen
    
    nummerbahn = [NSMutableDictionary new];
    int dreii = 0;
    
    for (NSString *key in nummerext) {
        NSString *realkey;
        realkey = [NSString stringWithFormat:@"%lld", key.longLongValue];
        
        [nummerbahn setValue:[stationlong objectAtIndex:dreii] forKey:realkey]; // Jetzt ein Dictionary erstellen, wo ich anhand der Equipmentnummer den Ort rauskrieg
        dreii++;
    }
    
//    NSLog(@"%@", nummerbahn);
    
    nummerbahnnow = [nummerbahn mutableCopy]; // Und das ganze global schalten. Finito!
    
}
-(NSMutableDictionary*)dicfromdata:(NSData*)responseData
{
    
    NSError* error;
    NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
//    NSLog(@"%@",json.description);
    
    return json;
}
///Fehler wegen Internet anzeigen
-(void)run_error
{
    UIAlertController *control;
    control = [UIAlertController alertControllerWithTitle:(@"Keine Verbindung") message:(@"Die Daten können nicht abgerufen werden. Es besteht keine aktive Verbindung zum Internet") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Erneut versuchen"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self startupcheck]; // Nochmal StartupCheck durchlaufen lassen
                         }];
    [control addAction:ok];
    
    
    [self presentViewController:control animated:YES completion:nil];
}
///Hier liegt das Herz der ganze Sache, wenn das nicht ausgeführt wird geht gar nichts
-(void)run_debut
{
    _loadingindicator = [[UIActivityIndicatorView alloc]initWithFrame:self.view.frame]; //Ladeding initializieren
    [self activateloader];
    
    ADAMCom *com;
    com = [[ADAMCom alloc]init]; // ADAMCom vorbereiten
    
    
    baguette = [[ADAMerci alloc]init]; //Und das ADAMerci vorbereiten
    baguette = [com dictionary_fromADAM];
    
    
    mapView = [[ADAM_MapView alloc]initWithFrame:self.view.frame]; // Jetzt kommt die ADAM_MapView!
    [self.view addSubview:mapView];
    mapView.viewc = (id)self;
    mapView.fromage = baguette; // Brot mit Käse
    
    [self.view addSubview:mapView];
    
    [mapView setup]; // aufsetzen
    [self.view addSubview:credits];
    
    // Hier kommt jetzt erstmal UI Gedöns
    datenschutz = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-self.view.frame.size.width/5, self.view.frame.size.height-15,self.view.frame.size.width/5, 10)];
    
    
    datenschutz.titleLabel.textAlignment = NSTextAlignmentRight;
    [datenschutz setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [datenschutz addTarget:self action:@selector(showprivacy) forControlEvents:UIControlEventPrimaryActionTriggered];
    [datenschutz setTitle:(@"Datenschutz") forState:UIControlStateNormal];
    [datenschutz.titleLabel setFont:[UIFont systemFontOfSize:self.view.frame.size.height/56]];
    [datenschutz setBackgroundColor:[UIColor whiteColor]];
    
//    [self.view addSubview:datenschutz];
    
    //Datenschutzvereinbarung anzeigen wenn noch nicht geschehen
    if (![[NSUserDefaults standardUserDefaults]boolForKey:(@"privacy2")])
    {
        [self showprivacy];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:(@"privacy2")];
    }
    
//    ortung = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-self.view.frame.size.width/10, self.view.frame.size.height-(35+self.view.frame.size.width/15),self.view.frame.size.width/10, self.view.frame.size.width/10)];
    ortung = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-50,50, 50)];
    
    [ortung setImage:[UIImage imageNamed:(@"smalladam.png")] forState:UIControlStateNormal];
    [self.view addSubview:ortung];
    ortung.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [ortung addTarget:self action:@selector(ortme) forControlEvents:UIControlEventPrimaryActionTriggered];
    // Das wars!
    printf("\n UI Bereit");
    
    
}
///Creditauswahl
-(void)showcreditalert
{
    UIAlertController *controller;
    controller = [UIAlertController alertControllerWithTitle:(@"Credits") message:(@"Danke an alle.") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* db = [UIAlertAction actionWithTitle:(@"Deutsche Bahn (DB)") style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[UIApplication sharedApplication]openURL:[NSURL URLWithString:(@"http://data.deutschebahn.com")]];
                                               }];
    UIAlertAction* freep = [UIAlertAction actionWithTitle:(@"Freepik | Flaticon") style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      [[UIApplication sharedApplication]openURL:[NSURL URLWithString:(@"http://www.freepik.com")]];
                                                  }];
    UIAlertAction* noscio = [UIAlertAction actionWithTitle:(@"Entwickelt von Jonathan Fritz") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [[UIApplication sharedApplication]openURL:[NSURL URLWithString:(@"https://noscio.eu")]];
                                                   }];
    UIAlertAction* close = [UIAlertAction actionWithTitle:(@"Schließen") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
    
    [controller addAction:db];
    [controller addAction:freep];
    [controller addAction:noscio];
    [controller addAction:close];
    
    [self presentViewController:controller animated:YES completion:nil];
}
///Userlocation zentrieren
-(void)ortme
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    CLLocationCoordinate2D location;
    location.latitude = mapView.map.userLocation.coordinate.latitude;
    location.longitude = mapView.map.userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [mapView.map setRegion:region animated:YES];
}
///Datenschutzcontroller anzeigen
-(void)showprivacy
{
    UIAlertController *priv;
    priv = [UIAlertController alertControllerWithTitle:(@"Datenschutz") message:(@"Deine Privatsphäre ist uns sehr wichtig. Deshalb stellt die App zu keinem Zeitpunkt eine Verbindung mit den Servern von Noscio her. Die Deutsche Bahn erhält möglicherweise bei dem Abrufen der Daten von ADAM Informationen darüber, welches Gerät du verwendest und wann du auf ADAM zugreifst. Dein Standort wird aber nicht übermittelt. Mit der Nutzung der App erklärst du dich mit diesen Bedingungen einverstanden.") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay;
    okay = [UIAlertAction actionWithTitle:(@"In Ordnung") style:UIAlertActionStyleDefault handler:nil];
    [priv addAction:okay];
    [self presentViewController:priv animated:YES completion:nil];
    
}
///Das muss man unbedingt ausschalten, das sieht sonst so unfassbar scheiße aus
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
//-(MKAnnotationView*) returnPointView: (CLLocationCoordinate2D) location andTitle: (NSString*) title andColor: (int) color{
//    /*Method that acts as a point-generating machine. Takes the parameters of the location, the title, and the color of the
//     pin, and it returns a view that holds the pin with those specified details*/
//    
//    printf("\n Working");
//    
//    
//    MKPointAnnotation *resultPin = [[MKPointAnnotation alloc] init];
//    MKPinAnnotationView *result = [[MKPinAnnotationView alloc] initWithAnnotation:resultPin reuseIdentifier:Nil];
//    [resultPin setCoordinate:location];
//    resultPin.title = title;
//    result.pinTintColor = [UIColor greenColor];
//    
//    return result;
//    
//}

// 2 unnütze Methoden
-(void)activateloader
{
    
}
-(void)deactivateloader
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    printf("\n Memory Warning erhalten. Dein Gerät ist scheiße"); //Nutzer beleidigen weil ich nicht effizient (genug) programmiert habe
    
}

@end
