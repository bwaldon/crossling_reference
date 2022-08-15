// see table for rotation 1
// every three items in the array correspond to one row of one gender
// does not repeat genders, because the gender is determined by the above code
// mention that these are references to noun IDS
  const rot1 = [
                // scene 1 ids
                [1, 7],
                [2, 8],
                [3, 9],
                // scene 2 ids
                [4, 10],
                [5, 11],
                [6, 12],
                // scene 3 ids
                [7, 1],
                [8, 2],
                [9, 3],
                // scene 4 ids
                [10, 4],
                [11, 5],
                [12, 6]];

  const rot2 = [
                // scene 1 ids
                [7, 1],
                [8, 2],
                [9, 3],
                // scene 2 ids
                [10, 4],
                [11, 5],
                [12, 6],
                // scene 3 ids
                [1, 7],
                [2, 8],
                [3, 9],
                // scene 4 ids
                [4, 10],
                [5, 11],
                [6, 12]];


  const rot3 = [
                // scene 1 ids
                [10, 4],
                [11, 5],
                [12, 6],
                // scene 2 ids
                [7, 1],
                [8, 2],
                [9, 3],
                // scene 3 ids
                [4, 10],
                [5, 11],
                [6, 12],
                // scene 4 ids
                [1, 7],
                [2, 8],
                [3, 9]];

  const rot4 = [
                // scene 1 ids
                [4, 10],
                [5, 11],
                [6, 12],
                // scene 2 ids
                [1, 7],
                [2, 8],
                [3, 9],
                // scene 3 ids
                [10, 4],
                [11, 5],
                [12, 6],
                // scene 4 ids
                [7, 1],
                [8, 2],
                [9, 3]];

export const allRotations = [rot1, rot2, rot3, rot4];
