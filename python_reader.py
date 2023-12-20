file = open('GlobalAirportDatabase.txt','r')

def convert_latitude_to_decimal(latitude):
    degrees, minutes, seconds, direction = latitude
    decimal_latitude = float(degrees) + float(minutes) / 60 + float(seconds) / 3600

    # Adjust the sign based on the direction (N or S)
    if direction.upper() == 'S':
        decimal_latitude *= -1

    return str(decimal_latitude)

def convert_longitude_to_decimal(longitude):
    degrees, minutes, seconds, direction = longitude
    decimal_longitude = float(degrees) + float(minutes) / 60 + float(seconds) / 3600

    # Adjust the sign based on the direction (E or W)
    if direction.upper() == 'W':
        decimal_longitude *= -1

    return str(decimal_longitude)


if __name__ == "__main__":

    f = open ("Airports.txt", "a")




    for i in file:

        line = i.split(":")

        IACO = line[0]
        Lat = line[5], line [6], line[7], line[8]

        long = line[9], line[10], line[11], line[12]

        if Lat[len(Lat) -1 ] != "U" and long[len(long) -1] != "U":

            f.write(IACO + ":" + convert_latitude_to_decimal(Lat) + ":" + convert_longitude_to_decimal(long) + ":")

            





    


            



