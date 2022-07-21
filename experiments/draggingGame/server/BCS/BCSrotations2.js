// see table for rotation 1
// every three items in the array correspond to one row of one gender
// does not repeat genders, because the gender is determined by the above code
// mention that these are references to noun IDS
const rot1 = [// scene 1 ids
              1, 2, 3,
              // scene 2 ids
              4, 5, 6,
              // scene 3 ids
              7, 8, 9,
              // scene 4 ids
              10, 11, 12];

const rot2 = [// scene 1 ids
              10, 11, 12,
              // scene 2 ids
              1, 2, 3,
              // scene 3 ids
              4, 5, 6,
              // scene 4 ids
              7, 8, 9];


const rot3 = [// scene 1 ids
              7, 8, 9,
              // scene 2 ids
              10, 11, 12,
              // scene 3 ids
              1, 2, 3,
              // scene 4 ids
              4, 5, 6];

const rot4 = [// scene 1 ids
              4, 5, 6,
              // scene 2 ids
              7, 8, 9,
              // scene 3 ids
              10, 11, 12,
              // scene 4 ids
              1, 2, 3];

export const allRotations = [rot1, rot2, rot3, rot4];
